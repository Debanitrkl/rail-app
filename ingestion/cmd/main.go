package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/rail-app/ingestion/internal/config"
	"github.com/rail-app/ingestion/internal/mockgen"
	"github.com/rail-app/ingestion/internal/publisher"
	"github.com/rail-app/ingestion/internal/scraper"
)

func main() {
	log.Println("Starting Rail Ingestion Worker...")

	cfg := config.Load()

	pub, err := publisher.New(cfg)
	if err != nil {
		log.Fatalf("Failed to create publisher: %v", err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	if cfg.MockData {
		log.Println("Running in mock data mode")
		mock := mockgen.New(cfg, pub)
		go mock.Start(ctx)
	} else {
		log.Println("Running in scraper mode")
		sc := scraper.New(cfg, pub)
		go sc.Start(ctx)
	}

	<-sigCh
	log.Println("Shutting down ingestion worker...")
	cancel()

	time.Sleep(2 * time.Second)
	log.Println("Ingestion worker stopped")
}
