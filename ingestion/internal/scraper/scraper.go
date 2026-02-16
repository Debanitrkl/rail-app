package scraper

import (
	"context"
	"database/sql"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"regexp"
	"strconv"
	"strings"
	"time"

	_ "github.com/lib/pq"

	"github.com/rail-app/ingestion/internal/config"
	"github.com/rail-app/ingestion/internal/publisher"
)

type TrainInfo struct {
	Number        string
	Name          string
	SourceStation string
	DestStation   string
}

type RouteStop struct {
	StationCode    string
	StopNumber     int
	ArrivalTime    sql.NullString
	DepartureTime  sql.NullString
	DistFromSource int
	DayNumber      int
	Platform       sql.NullString
	Latitude       float64
	Longitude      float64
}

type RunningEvent struct {
	Type        string // "Arrived" or "Departed"
	StationCode string
	StationName string
	Time        string
	DelayMin    int
	Platform    string
}

type Scraper struct {
	cfg        *config.Config
	pub        *publisher.Publisher
	db         *sql.DB
	httpClient *http.Client
	csrfKey    string
	csrfValue  string
}

func New(cfg *config.Config, pub *publisher.Publisher) *Scraper {
	jar, _ := cookiejar.New(nil)
	return &Scraper{
		cfg: cfg,
		pub: pub,
		httpClient: &http.Client{
			Timeout: 15 * time.Second,
			Jar:     jar,
		},
	}
}

func (s *Scraper) Start(ctx context.Context) {
	connStr := fmt.Sprintf(
		"host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		s.cfg.PostgresHost, s.cfg.PostgresPort,
		s.cfg.PostgresUser, s.cfg.PostgresPassword, s.cfg.PostgresDB,
	)

	var err error
	s.db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Printf("Failed to connect to database: %v", err)
		return
	}
	defer s.db.Close()

	for i := 0; i < 30; i++ {
		if err := s.db.Ping(); err == nil {
			break
		}
		log.Println("Waiting for database...")
		time.Sleep(2 * time.Second)
	}

	log.Println("Real data scraper started")
	ticker := time.NewTicker(time.Duration(s.cfg.PollInterval) * time.Second)
	defer ticker.Stop()

	s.scrapeAll(ctx)

	for {
		select {
		case <-ctx.Done():
			log.Println("Scraper stopping...")
			return
		case <-ticker.C:
			s.scrapeAll(ctx)
		}
	}
}

func (s *Scraper) scrapeAll(ctx context.Context) {
	trains, err := s.getActiveTrains()
	if err != nil {
		log.Printf("Failed to get active trains: %v", err)
		return
	}

	// Refresh NTES session before each batch
	if err := s.initNTESSession(ctx); err != nil {
		log.Printf("NTES session init failed: %v, will try eRail fallback", err)
	}

	log.Printf("Scraping real data for %d trains...", len(trains))

	for _, train := range trains {
		select {
		case <-ctx.Done():
			return
		default:
			s.scrapeTrain(ctx, train)
			// Rate limit: 1 request per 2 seconds to be respectful
			time.Sleep(2 * time.Second)
		}
	}
}

// ---- NTES Session Management ----

func (s *Scraper) initNTESSession(ctx context.Context) error {
	// Step 1: Bootstrap session
	req, err := http.NewRequestWithContext(ctx, "GET", s.cfg.NTESBaseURL+"/mntes/", nil)
	if err != nil {
		return fmt.Errorf("create bootstrap request: %w", err)
	}
	req.Header.Set("User-Agent", userAgent)
	resp, err := s.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("bootstrap request: %w", err)
	}
	resp.Body.Close()

	// Step 2: Get CSRF token
	ts := time.Now().UnixMilli()
	csrfURL := fmt.Sprintf("%s/mntes/GetCSRFToken?t=%d", s.cfg.NTESBaseURL, ts)
	req, err = http.NewRequestWithContext(ctx, "GET", csrfURL, nil)
	if err != nil {
		return fmt.Errorf("create csrf request: %w", err)
	}
	req.Header.Set("User-Agent", userAgent)
	req.Header.Set("X-Requested-With", "XMLHttpRequest")
	req.Header.Set("Referer", s.cfg.NTESBaseURL+"/mntes/")

	resp, err = s.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("csrf request: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("read csrf body: %w", err)
	}

	// Parse: name='key' value='value'
	re := regexp.MustCompile(`name='([^']+)'\s+value='([^']+)'`)
	matches := re.FindSubmatch(body)
	if len(matches) < 3 {
		return fmt.Errorf("could not extract CSRF token from response: %s", string(body[:min(200, len(body))]))
	}

	s.csrfKey = string(matches[1])
	s.csrfValue = string(matches[2])
	log.Printf("NTES session initialized (CSRF key: %s)", s.csrfKey)
	return nil
}

// ---- Train Scraping ----

func (s *Scraper) scrapeTrain(ctx context.Context, train TrainInfo) {
	// Try NTES first
	events, err := s.fetchFromNTES(ctx, train.Number)
	if err != nil {
		log.Printf("NTES failed for %s: %v, trying eRail...", train.Number, err)
		// Fallback to eRail
		events, err = s.fetchFromERail(ctx, train.Number)
		if err != nil {
			log.Printf("eRail also failed for %s: %v", train.Number, err)
			return
		}
	}

	if len(events) == 0 {
		log.Printf("No running data for %s (%s) — train may not be running today", train.Number, train.Name)
		return
	}

	// Get route info for GPS coordinates
	route, _ := s.getTrainRoute(train.Number)
	stationCoords := make(map[string][2]float64)
	for _, stop := range route {
		stationCoords[stop.StationCode] = [2]float64{stop.Latitude, stop.Longitude}
	}

	// Process events and publish
	s.processEvents(ctx, train, events, stationCoords)
}

// ---- NTES Fetcher ----

func (s *Scraper) fetchFromNTES(ctx context.Context, trainNumber string) ([]RunningEvent, error) {
	if s.csrfKey == "" {
		return nil, fmt.Errorf("no CSRF token available")
	}

	now := time.Now()
	refDate := now.Format("02-Jan-2006") // DD-Mon-YYYY

	ntesURL := fmt.Sprintf(
		"%s/mntes/tr?opt=TrainRunning&subOpt=FindRunningInstance&refDate=%s",
		s.cfg.NTESBaseURL, refDate,
	)

	formData := url.Values{
		"lan":      {"en"},
		"jDate":    {refDate},
		"trainNo":  {trainNumber},
		s.csrfKey:  {s.csrfValue},
	}

	req, err := http.NewRequestWithContext(ctx, "POST", ntesURL, strings.NewReader(formData.Encode()))
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	req.Header.Set("User-Agent", userAgent)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Set("X-Requested-With", "XMLHttpRequest")
	req.Header.Set("Referer", s.cfg.NTESBaseURL+"/mntes/")
	req.Header.Set("Origin", s.cfg.NTESBaseURL)
	req.Header.Set("Accept", "*/*")
	req.Header.Set("Cache-Control", "no-cache")

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("http request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("NTES returned status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read body: %w", err)
	}

	return parseNTESResponse(string(body))
}

func parseNTESResponse(html string) ([]RunningEvent, error) {
	var events []RunningEvent

	// NTES returns HTML with lines containing station events
	// Patterns:
	//   "Departed from Station Name (CODE) at HH:MM DD-Mon Delay: HH:MM"
	//   "Arrived at Station Name (CODE) at HH:MM DD-Mon Delay: HH:MM"
	//   "Arrived at Station Name (CODE) at HH:MM DD-Mon On Time"

	departedRe := regexp.MustCompile(`Departed\s+from\s+(.+?)\s*\((\w+)\)\s+at\s+(\d{2}:\d{2})\s+\d{2}-\w{3}(?:\s+Delay:\s*(\d{2}):(\d{2}))?`)
	arrivedRe := regexp.MustCompile(`Arrived\s+at\s+(.+?)\s*\((\w+)\)\s+at\s+(\d{2}:\d{2})\s+\d{2}-\w{3}(?:\s+Delay:\s*(\d{2}):(\d{2}))?`)
	platformRe := regexp.MustCompile(`(?:PF|Platform)\s*#?\s*(\d+)`)

	lines := strings.Split(html, "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)

		if matches := departedRe.FindStringSubmatch(line); len(matches) > 0 {
			ev := RunningEvent{
				Type:        "Departed",
				StationName: strings.TrimSpace(matches[1]),
				StationCode: matches[2],
				Time:        matches[3],
			}
			if matches[4] != "" && matches[5] != "" {
				hours, _ := strconv.Atoi(matches[4])
				mins, _ := strconv.Atoi(matches[5])
				ev.DelayMin = hours*60 + mins
			}
			if pfMatch := platformRe.FindStringSubmatch(line); len(pfMatch) > 0 {
				ev.Platform = pfMatch[1]
			}
			events = append(events, ev)
		}

		if matches := arrivedRe.FindStringSubmatch(line); len(matches) > 0 {
			ev := RunningEvent{
				Type:        "Arrived",
				StationName: strings.TrimSpace(matches[1]),
				StationCode: matches[2],
				Time:        matches[3],
			}
			if matches[4] != "" && matches[5] != "" {
				hours, _ := strconv.Atoi(matches[4])
				mins, _ := strconv.Atoi(matches[5])
				ev.DelayMin = hours*60 + mins
			}
			if pfMatch := platformRe.FindStringSubmatch(line); len(pfMatch) > 0 {
				ev.Platform = pfMatch[1]
			}
			events = append(events, ev)
		}
	}

	return events, nil
}

// ---- eRail Fallback Fetcher ----

func (s *Scraper) fetchFromERail(ctx context.Context, trainNumber string) ([]RunningEvent, error) {
	erailURL := fmt.Sprintf(
		"https://erail.in/data.aspx?Action=TRAINROUTE&Password=2012&Data1=%s&Data2=0&Cache=true",
		trainNumber,
	)

	req, err := http.NewRequestWithContext(ctx, "GET", erailURL, nil)
	if err != nil {
		return nil, fmt.Errorf("create erail request: %w", err)
	}
	req.Header.Set("User-Agent", userAgent)

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("erail request: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read erail body: %w", err)
	}

	return parseERailResponse(string(body))
}

func parseERailResponse(data string) ([]RunningEvent, error) {
	var events []RunningEvent

	// eRail returns delimited text with ~ separator
	// Format varies but generally:
	// Fields separated by ~ containing station code, name, arrival, departure, delay etc.
	segments := strings.Split(data, "~~~~~~~~")
	if len(segments) < 2 {
		// Try alternate delimiter
		segments = strings.Split(data, "~^")
	}

	for _, segment := range segments {
		fields := strings.Split(strings.TrimSpace(segment), "~")
		if len(fields) < 5 {
			continue
		}

		// Try to extract station info from fields
		// eRail format: StationCode~StationName~Arrival~Departure~Day~Distance~...
		stationCode := strings.TrimSpace(fields[0])
		if len(stationCode) < 2 || len(stationCode) > 6 {
			continue
		}

		ev := RunningEvent{
			StationCode: stationCode,
			StationName: strings.TrimSpace(fields[1]),
		}

		if len(fields) > 2 && fields[2] != "" && fields[2] != "Source" {
			ev.Time = strings.TrimSpace(fields[2])
			ev.Type = "Arrived"
		}
		if len(fields) > 3 && fields[3] != "" && fields[3] != "Destination" {
			ev.Time = strings.TrimSpace(fields[3])
			ev.Type = "Departed"
		}

		// Look for delay info in later fields
		for _, f := range fields[4:] {
			f = strings.TrimSpace(f)
			if strings.Contains(f, "late") || strings.Contains(f, "delay") {
				delayRe := regexp.MustCompile(`(\d+)\s*(?:min|hr)`)
				if m := delayRe.FindStringSubmatch(f); len(m) > 0 {
					ev.DelayMin, _ = strconv.Atoi(m[1])
				}
			}
		}

		if ev.Type != "" {
			events = append(events, ev)
		}
	}

	return events, nil
}

// ---- Event Processing & Publishing ----

func (s *Scraper) processEvents(ctx context.Context, train TrainInfo, events []RunningEvent, stationCoords map[string][2]float64) {
	if len(events) == 0 {
		return
	}

	// The last event tells us the current position
	lastEvent := events[len(events)-1]
	now := time.Now().UTC()

	// Get coordinates for the station
	lat, lng := 0.0, 0.0
	if coords, ok := stationCoords[lastEvent.StationCode]; ok {
		lat = coords[0]
		lng = coords[1]
	}

	// Determine next station from route
	nextStation := ""
	route, _ := s.getTrainRoute(train.Number)
	for i, stop := range route {
		if stop.StationCode == lastEvent.StationCode && i+1 < len(route) {
			nextStation = route[i+1].StationCode
			break
		}
	}

	// Calculate ETA for next station (rough estimate)
	etaNext := now.Add(30 * time.Minute).Format(time.RFC3339)

	// Publish train position
	pos := publisher.TrainPosition{
		TrainNumber:    train.Number,
		Latitude:       lat,
		Longitude:      lng,
		SpeedKmph:      estimateSpeed(lastEvent),
		DelayMinutes:   lastEvent.DelayMin,
		CurrentStation: lastEvent.StationCode,
		NextStation:    nextStation,
		ETANext:        etaNext,
		Timestamp:      now.Format(time.RFC3339),
	}

	if err := s.pub.PublishTrainPosition(ctx, pos); err != nil {
		log.Printf("Failed to publish position for %s: %v", train.Number, err)
	} else {
		log.Printf("[REAL] %s (%s): %s at %s, delay=%dm, speed≈%dkm/h",
			train.Number, train.Name, lastEvent.Type, lastEvent.StationCode,
			lastEvent.DelayMin, pos.SpeedKmph)
	}

	// Publish platform changes
	for _, ev := range events {
		if ev.Platform != "" {
			platEvent := publisher.PlatformChange{
				StationCode:    ev.StationCode,
				PlatformNumber: ev.Platform,
				TrainNumber:    train.Number,
				EventType:      strings.ToLower(ev.Type),
				Timestamp:      now.Format(time.RFC3339),
			}
			s.pub.PublishPlatformChange(ctx, platEvent)
		}
	}

	// Publish delay events for delayed trains
	if lastEvent.DelayMin > 0 {
		delayEv := publisher.DelayEvent{
			TrainNumber:   train.Number,
			StationCode:   lastEvent.StationCode,
			ScheduledTime: lastEvent.Time,
			ActualTime:    now.Format("15:04"),
			DelayMinutes:  lastEvent.DelayMin,
			Cause:         "Reported by NTES",
			Timestamp:     now.Format(time.RFC3339),
		}
		s.pub.PublishDelayEvent(ctx, delayEv)
	}
}

func estimateSpeed(event RunningEvent) int {
	if event.Type == "Arrived" {
		return 0 // Stationary at station
	}
	// Rough estimate for running train
	if event.DelayMin > 30 {
		return 40 + (event.DelayMin % 30) // Slower when delayed
	}
	return 80 + (event.DelayMin % 40) // Normal speed range
}

// ---- Database Queries ----

func (s *Scraper) getActiveTrains() ([]TrainInfo, error) {
	rows, err := s.db.Query(`
		SELECT number, name, source_station, destination_station
		FROM trains
		LIMIT 50
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var trains []TrainInfo
	for rows.Next() {
		var t TrainInfo
		var src, dst sql.NullString
		if err := rows.Scan(&t.Number, &t.Name, &src, &dst); err != nil {
			log.Printf("Failed to scan train: %v", err)
			continue
		}
		t.SourceStation = src.String
		t.DestStation = dst.String
		trains = append(trains, t)
	}
	return trains, nil
}

func (s *Scraper) getTrainRoute(trainNumber string) ([]RouteStop, error) {
	rows, err := s.db.Query(`
		SELECT tr.station_code, tr.stop_number, tr.arrival_time, tr.departure_time,
			   tr.distance_from_source, tr.day_number, tr.platform,
			   COALESCE(s.latitude, 0), COALESCE(s.longitude, 0)
		FROM train_routes tr
		JOIN stations s ON s.code = tr.station_code
		WHERE tr.train_number = $1
		ORDER BY tr.stop_number ASC
	`, trainNumber)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var stops []RouteStop
	for rows.Next() {
		var stop RouteStop
		if err := rows.Scan(
			&stop.StationCode, &stop.StopNumber,
			&stop.ArrivalTime, &stop.DepartureTime,
			&stop.DistFromSource, &stop.DayNumber, &stop.Platform,
			&stop.Latitude, &stop.Longitude,
		); err != nil {
			log.Printf("Failed to scan route stop: %v", err)
			continue
		}
		stops = append(stops, stop)
	}
	return stops, nil
}

// ---- Constants ----

const userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
