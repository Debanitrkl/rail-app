package publisher

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/redis/go-redis/v9"

	"github.com/rail-app/ingestion/internal/config"
)

type TrainPosition struct {
	TrainNumber    string  `json:"train_number"`
	Latitude       float64 `json:"latitude"`
	Longitude      float64 `json:"longitude"`
	SpeedKmph      int     `json:"speed_kmph"`
	DelayMinutes   int     `json:"delay_minutes"`
	CurrentStation string  `json:"current_station"`
	NextStation    string  `json:"next_station"`
	ETANext        string  `json:"eta_next"`
	Timestamp      string  `json:"timestamp"`
}

type PlatformChange struct {
	StationCode    string `json:"station_code"`
	PlatformNumber string `json:"platform_number"`
	TrainNumber    string `json:"train_number"`
	EventType      string `json:"event_type"`
	Timestamp      string `json:"timestamp"`
}

type DelayEvent struct {
	TrainNumber   string `json:"train_number"`
	StationCode   string `json:"station_code"`
	ScheduledTime string `json:"scheduled_time"`
	ActualTime    string `json:"actual_time"`
	DelayMinutes  int    `json:"delay_minutes"`
	Cause         string `json:"cause"`
	Timestamp     string `json:"timestamp"`
}

type PnrStatusChange struct {
	PNR       string `json:"pnr"`
	OldStatus string `json:"old_status"`
	NewStatus string `json:"new_status"`
	Coach     string `json:"coach"`
	Berth     string `json:"berth"`
	Timestamp string `json:"timestamp"`
}

type Publisher struct {
	cfg        *config.Config
	httpClient *http.Client
	authHeader string
	rdb        *redis.Client
}

func New(cfg *config.Config) (*Publisher, error) {
	auth := base64.StdEncoding.EncodeToString(
		[]byte(fmt.Sprintf("%s:%s", cfg.ParseableUser, cfg.ParseablePassword)),
	)

	rdb := redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:%d", cfg.ValkeyHost, cfg.ValkeyPort),
	})

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := rdb.Ping(ctx).Err(); err != nil {
		log.Printf("Warning: Could not connect to Valkey: %v", err)
	} else {
		log.Println("Connected to Valkey")
	}

	return &Publisher{
		cfg: cfg,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
		authHeader: "Basic " + auth,
		rdb:        rdb,
	}, nil
}

func (p *Publisher) PublishTrainPosition(ctx context.Context, pos TrainPosition) error {
	if err := p.ingestToParseable("train-positions", []interface{}{pos}); err != nil {
		return fmt.Errorf("parseable ingest failed: %w", err)
	}

	data, err := json.Marshal(pos)
	if err != nil {
		return fmt.Errorf("json marshal failed: %w", err)
	}

	channel := fmt.Sprintf("train:live:%s", pos.TrainNumber)
	if err := p.rdb.Publish(ctx, channel, string(data)).Err(); err != nil {
		log.Printf("Warning: Valkey publish failed for %s: %v", channel, err)
	}

	if pos.CurrentStation != "" {
		stationChannel := fmt.Sprintf("station:live:%s", pos.CurrentStation)
		if err := p.rdb.Publish(ctx, stationChannel, string(data)).Err(); err != nil {
			log.Printf("Warning: Valkey publish failed for %s: %v", stationChannel, err)
		}
	}

	return nil
}

func (p *Publisher) PublishPlatformChange(ctx context.Context, event PlatformChange) error {
	if err := p.ingestToParseable("platform-changes", []interface{}{event}); err != nil {
		return fmt.Errorf("parseable ingest failed: %w", err)
	}

	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("json marshal failed: %w", err)
	}

	channel := fmt.Sprintf("station:live:%s", event.StationCode)
	if err := p.rdb.Publish(ctx, channel, string(data)).Err(); err != nil {
		log.Printf("Warning: Valkey publish failed: %v", err)
	}

	return nil
}

func (p *Publisher) PublishDelayEvent(ctx context.Context, event DelayEvent) error {
	if err := p.ingestToParseable("delay-events", []interface{}{event}); err != nil {
		return fmt.Errorf("parseable ingest failed: %w", err)
	}

	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("json marshal failed: %w", err)
	}

	channel := fmt.Sprintf("train:live:%s", event.TrainNumber)
	if err := p.rdb.Publish(ctx, channel, string(data)).Err(); err != nil {
		log.Printf("Warning: Valkey publish failed: %v", err)
	}

	return nil
}

func (p *Publisher) PublishPnrStatusChange(ctx context.Context, event PnrStatusChange) error {
	if err := p.ingestToParseable("pnr-status-changes", []interface{}{event}); err != nil {
		return fmt.Errorf("parseable ingest failed: %w", err)
	}

	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("json marshal failed: %w", err)
	}

	channel := fmt.Sprintf("pnr:update:%s", event.PNR)
	if err := p.rdb.Publish(ctx, channel, string(data)).Err(); err != nil {
		log.Printf("Warning: Valkey publish failed: %v", err)
	}

	return nil
}

func (p *Publisher) ingestToParseable(stream string, events []interface{}) error {
	body, err := json.Marshal(events)
	if err != nil {
		return fmt.Errorf("json marshal failed: %w", err)
	}

	url := fmt.Sprintf("%s/api/v1/logstream/%s", p.cfg.ParseableURL, stream)
	req, err := http.NewRequest("POST", url, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create request failed: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", p.authHeader)
	req.Header.Set("X-P-Stream", stream)

	resp, err := p.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("http request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("parseable returned status %d", resp.StatusCode)
	}

	return nil
}
