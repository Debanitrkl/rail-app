package mockgen

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"math"
	"math/rand"
	"time"

	_ "github.com/lib/pq"

	"github.com/rail-app/ingestion/internal/config"
	"github.com/rail-app/ingestion/internal/publisher"
)

type trainRoute struct {
	TrainNumber string
	TrainName   string
	Stops       []routeStop
}

type routeStop struct {
	StationCode    string
	StopNumber     int
	ArrivalTime    string
	DepartureTime  string
	DistFromSource int
	DayNumber      int
	Platform       string
	Latitude       float64
	Longitude      float64
}

type MockGenerator struct {
	cfg    *config.Config
	pub    *publisher.Publisher
	db     *sql.DB
	routes []trainRoute
	rng    *rand.Rand
}

func New(cfg *config.Config, pub *publisher.Publisher) *MockGenerator {
	return &MockGenerator{
		cfg: cfg,
		pub: pub,
		rng: rand.New(rand.NewSource(time.Now().UnixNano())),
	}
}

func (m *MockGenerator) Start(ctx context.Context) {
	connStr := fmt.Sprintf(
		"host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		m.cfg.PostgresHost, m.cfg.PostgresPort,
		m.cfg.PostgresUser, m.cfg.PostgresPassword, m.cfg.PostgresDB,
	)

	var err error
	for i := 0; i < 30; i++ {
		m.db, err = sql.Open("postgres", connStr)
		if err == nil {
			if pingErr := m.db.Ping(); pingErr == nil {
				break
			}
		}
		log.Println("Waiting for database connection...")
		time.Sleep(2 * time.Second)
	}

	if err != nil {
		log.Printf("Failed to connect to database: %v", err)
		return
	}
	defer m.db.Close()

	// Load train routes from database
	if err := m.loadRoutes(); err != nil {
		log.Printf("Failed to load routes: %v", err)
		return
	}

	log.Printf("Loaded %d train routes for mock generation", len(m.routes))

	ticker := time.NewTicker(time.Duration(m.cfg.PollInterval) * time.Second)
	defer ticker.Stop()

	// Initial generation
	m.generateAll(ctx)

	for {
		select {
		case <-ctx.Done():
			log.Println("Mock generator stopping...")
			return
		case <-ticker.C:
			m.generateAll(ctx)
		}
	}
}

func (m *MockGenerator) loadRoutes() error {
	rows, err := m.db.Query(`
		SELECT DISTINCT t.number, t.name
		FROM trains t
		INNER JOIN train_routes tr ON tr.train_number = t.number
		ORDER BY t.number
	`)
	if err != nil {
		return err
	}
	defer rows.Close()

	var trainNumbers []struct {
		Number string
		Name   string
	}
	for rows.Next() {
		var tn struct {
			Number string
			Name   string
		}
		if err := rows.Scan(&tn.Number, &tn.Name); err != nil {
			continue
		}
		trainNumbers = append(trainNumbers, tn)
	}

	for _, tn := range trainNumbers {
		route, err := m.loadTrainRoute(tn.Number, tn.Name)
		if err != nil {
			log.Printf("Failed to load route for %s: %v", tn.Number, err)
			continue
		}
		if len(route.Stops) > 0 {
			m.routes = append(m.routes, route)
		}
	}

	return nil
}

func (m *MockGenerator) loadTrainRoute(trainNumber, trainName string) (trainRoute, error) {
	rows, err := m.db.Query(`
		SELECT tr.station_code, tr.stop_number,
			   COALESCE(tr.arrival_time::text, ''),
			   COALESCE(tr.departure_time::text, ''),
			   tr.distance_from_source, tr.day_number,
			   COALESCE(tr.platform, ''),
			   COALESCE(s.latitude, 0), COALESCE(s.longitude, 0)
		FROM train_routes tr
		JOIN stations s ON s.code = tr.station_code
		WHERE tr.train_number = $1
		ORDER BY tr.stop_number ASC
	`, trainNumber)
	if err != nil {
		return trainRoute{}, err
	}
	defer rows.Close()

	route := trainRoute{
		TrainNumber: trainNumber,
		TrainName:   trainName,
	}

	for rows.Next() {
		var stop routeStop
		if err := rows.Scan(
			&stop.StationCode, &stop.StopNumber,
			&stop.ArrivalTime, &stop.DepartureTime,
			&stop.DistFromSource, &stop.DayNumber,
			&stop.Platform, &stop.Latitude, &stop.Longitude,
		); err != nil {
			log.Printf("Failed to scan stop: %v", err)
			continue
		}
		route.Stops = append(route.Stops, stop)
	}

	return route, nil
}

func (m *MockGenerator) generateAll(ctx context.Context) {
	now := time.Now()
	log.Printf("Generating mock data at %s for %d trains", now.Format(time.RFC3339), len(m.routes))

	for _, route := range m.routes {
		select {
		case <-ctx.Done():
			return
		default:
			m.generateTrainPosition(ctx, route, now)
		}
	}
}

func (m *MockGenerator) generateTrainPosition(ctx context.Context, route trainRoute, now time.Time) {
	if len(route.Stops) < 2 {
		return
	}

	// Simulate train position between two stops
	// Pick a random segment of the route
	segIdx := m.rng.Intn(len(route.Stops) - 1)
	fromStop := route.Stops[segIdx]
	toStop := route.Stops[segIdx+1]

	// Random progress between stops (0.0 to 1.0)
	progress := m.rng.Float64()

	lat := fromStop.Latitude + (toStop.Latitude-fromStop.Latitude)*progress
	lng := fromStop.Longitude + (toStop.Longitude-fromStop.Longitude)*progress

	// Add some noise
	lat += (m.rng.Float64() - 0.5) * 0.01
	lng += (m.rng.Float64() - 0.5) * 0.01

	// Random speed between 40 and 130 kmph
	speed := 40 + m.rng.Intn(90)

	// Random delay (mostly 0, sometimes up to 120 min)
	delay := 0
	if m.rng.Float64() < 0.3 {
		delay = m.rng.Intn(120)
	}

	// Calculate ETA to next station
	distToNext := float64(toStop.DistFromSource-fromStop.DistFromSource) * (1 - progress)
	etaMinutes := 0
	if speed > 0 {
		etaMinutes = int(math.Round(distToNext / float64(speed) * 60))
	}
	etaNext := now.Add(time.Duration(etaMinutes) * time.Minute).Format(time.RFC3339)

	pos := publisher.TrainPosition{
		TrainNumber:    route.TrainNumber,
		Latitude:       math.Round(lat*10000000) / 10000000,
		Longitude:      math.Round(lng*10000000) / 10000000,
		SpeedKmph:      speed,
		DelayMinutes:   delay,
		CurrentStation: fromStop.StationCode,
		NextStation:    toStop.StationCode,
		ETANext:        etaNext,
		Timestamp:      now.Format(time.RFC3339),
	}

	if err := m.pub.PublishTrainPosition(ctx, pos); err != nil {
		log.Printf("Failed to publish position for %s: %v", route.TrainNumber, err)
	} else {
		log.Printf("Published position for %s (%s): %.4f,%.4f speed=%d delay=%d",
			route.TrainNumber, route.TrainName, lat, lng, speed, delay)
	}

	// Occasionally generate delay events
	if delay > 10 && m.rng.Float64() < 0.5 {
		causes := []string{
			"Fog/Low Visibility",
			"Signal Failure",
			"Track Maintenance",
			"Congestion",
			"Waiting for Crossing",
			"Late Departure",
			"Technical Issue",
			"Caution Order",
		}

		delayEvent := publisher.DelayEvent{
			TrainNumber:   route.TrainNumber,
			StationCode:   fromStop.StationCode,
			ScheduledTime: now.Add(-time.Duration(delay) * time.Minute).Format(time.RFC3339),
			ActualTime:    now.Format(time.RFC3339),
			DelayMinutes:  delay,
			Cause:         causes[m.rng.Intn(len(causes))],
			Timestamp:     now.Format(time.RFC3339),
		}

		if err := m.pub.PublishDelayEvent(ctx, delayEvent); err != nil {
			log.Printf("Failed to publish delay event for %s: %v", route.TrainNumber, err)
		}
	}

	// Occasionally generate platform changes
	if m.rng.Float64() < 0.2 {
		platformEvent := publisher.PlatformChange{
			StationCode:    fromStop.StationCode,
			PlatformNumber: fromStop.Platform,
			TrainNumber:    route.TrainNumber,
			EventType:      "arrival",
			Timestamp:      now.Format(time.RFC3339),
		}

		if platformEvent.PlatformNumber == "" {
			platformEvent.PlatformNumber = fmt.Sprintf("%d", 1+m.rng.Intn(10))
		}

		if err := m.pub.PublishPlatformChange(ctx, platformEvent); err != nil {
			log.Printf("Failed to publish platform event: %v", err)
		}
	}
}
