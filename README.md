# Rail — Indian Railway Tracker

A premium, full-stack Indian Railways tracking application. Native iOS app built with SwiftUI, powered by a NestJS backend, PostgreSQL database, Go ingestion worker, and real-time SSE streaming.

## Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [iOS App](#ios-app)
  - [Features](#features)
  - [Screens](#screens)
  - [Design System](#design-system)
  - [Requirements](#ios-requirements)
  - [Building the iOS App](#building-the-ios-app)
- [Backend API](#backend-api)
  - [API Endpoints](#api-endpoints)
  - [Services](#backend-services)
  - [Queue Processors](#queue-processors)
- [Database](#database)
  - [Schema](#schema)
  - [Migrations](#migrations)
  - [Seeds](#seeds)
- [Ingestion Worker](#ingestion-worker)
- [Infrastructure](#infrastructure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [Development Setup](#development-setup)
  - [iOS Development](#ios-development)
- [API Reference](#api-reference)
- [Configuration](#configuration)
- [Makefile Commands](#makefile-commands)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

Rail is a Flighty-inspired Indian Railways companion app that brings real-time train tracking, journey management, PNR status checking, and station information into a beautiful, dark-themed native iOS experience.

The system consists of:

- **iOS App** — Native SwiftUI app with MapKit integration, live activity support, and home screen widgets
- **Backend API** — NestJS REST API with TypeORM, Swagger docs, and Server-Sent Events for real-time updates
- **Database** — PostgreSQL 16 with migrations and seed data for stations, trains, routes, and coach compositions
- **Ingestion Worker** — Go service that polls Indian Railways NTES for live train positions and publishes events
- **Infrastructure** — Docker Compose orchestration with Caddy reverse proxy, Valkey (Redis) cache, Meilisearch full-text search, and Parseable observability

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        iOS App (SwiftUI)                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ Journeys │ │  Track   │ │  Detail  │ │  Search  │          │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘          │
│       └─────────────┼───────────┼─────────────┘                │
│                     │    REST + SSE                             │
└─────────────────────┼──────────────────────────────────────────┘
                      │
┌─────────────────────┼──────────────────────────────────────────┐
│                  Caddy (Reverse Proxy)                          │
└─────────────────────┼──────────────────────────────────────────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
┌────────▼──┐  ┌──────▼───┐  ┌────▼─────┐
│  NestJS   │  │ Meili    │  │ Parseable│
│  API      │  │ Search   │  │ Logging  │
└─────┬─────┘  └──────────┘  └──────────┘
      │                            ▲
┌─────▼─────┐  ┌──────────┐       │
│ PostgreSQL│  │  Valkey   │  ┌────┴─────┐
│    16     │  │  (Redis)  │  │   Go     │
└───────────┘  └──────────┘  │ Ingestion│
                              └──────────┘
```

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| iOS App | SwiftUI, MapKit, Observation | Native UI with real-time maps |
| iOS Widgets | WidgetKit, ActivityKit | Home screen & Live Activities |
| Backend | NestJS, TypeScript, TypeORM | REST API + SSE streaming |
| Database | PostgreSQL 16 | Relational data store |
| Cache | Valkey (Redis-compatible) | Session cache, rate limiting |
| Search | Meilisearch | Full-text search for trains/stations |
| Queue | BullMQ + ioredis | Background job processing |
| Ingestion | Go 1.21 | NTES scraping & event publishing |
| Observability | Parseable | Structured log aggregation |
| Proxy | Caddy | HTTPS, reverse proxy, CORS |
| Container | Docker Compose | Service orchestration |

---

## Project Structure

```
rail-app/
├── Rail/                          # iOS application
│   ├── Rail/
│   │   ├── Components/            # Reusable UI components (14 files)
│   │   ├── Config/                # App configuration
│   │   ├── Extensions/            # Swift extensions
│   │   ├── LiveActivity/          # iOS Live Activity support
│   │   ├── Models/                # Data models (11 files)
│   │   ├── Networking/            # API client, SSE, endpoints
│   │   ├── Services/              # Business logic services (7 files)
│   │   ├── Theme/                 # Design system (colors, typography, spacing)
│   │   ├── ViewModels/            # MVVM view models (5 files)
│   │   ├── Views/                 # Screen implementations
│   │   │   ├── IndiaMap/          # Live train map of India
│   │   │   ├── JourneyDetail/     # Journey detail screens
│   │   │   ├── Journeys/          # Home screen & cards
│   │   │   ├── LiveTracking/      # MapKit live tracking
│   │   │   ├── Search/            # Search & PNR screens
│   │   │   └── StationInfo/       # Station information
│   │   ├── ContentView.swift      # Root navigation
│   │   └── RailApp.swift          # App entry point
│   ├── RailWidget/                # Widget extension
│   │   ├── JourneyWidget/         # Journey home screen widget
│   │   └── PNRWidget/             # PNR status widget
│   ├── Rail.xcodeproj/            # Xcode project
│   └── project.yml                # XcodeGen specification
├── backend/                       # NestJS API server
│   ├── src/
│   │   ├── stations/              # Station CRUD + search
│   │   ├── trains/                # Train info + routes + live
│   │   ├── journeys/              # Journey management
│   │   ├── pnr/                   # PNR status + watchlist
│   │   ├── notifications/         # Push notification system
│   │   ├── search/                # Meilisearch integration
│   │   ├── widget/                # iOS widget data endpoints
│   │   ├── cache/                 # Valkey cache layer
│   │   ├── queue/                 # BullMQ job processing
│   │   │   └── processors/        # Background job handlers
│   │   ├── health/                # Health check endpoint
│   │   ├── metrics/               # API metrics
│   │   ├── parseable/             # Observability integration
│   │   └── common/                # Shared entities, DTOs, filters
│   ├── Dockerfile
│   └── package.json
├── database/                      # PostgreSQL
│   ├── migrations/                # 9 SQL migration files
│   ├── seeds/                     # 4 seed data files
│   └── init.sh                    # Database initialization
├── ingestion/                     # Go worker service
│   ├── cmd/main.go                # Entry point
│   ├── internal/
│   │   ├── config/                # Configuration
│   │   ├── scraper/               # NTES data scraper
│   │   ├── publisher/             # Event publisher
│   │   └── mockgen/               # Mock data generator
│   ├── Dockerfile
│   └── go.mod
├── scripts/                       # Utility scripts
│   ├── dev.sh                     # Development setup
│   ├── migrate.sh                 # Run migrations
│   ├── seed.sh                    # Seed database
│   ├── setup-parseable.sh         # Configure Parseable
│   └── setup-meilisearch.sh       # Configure Meilisearch
├── docs/                          # GitHub Pages website
├── docker-compose.yml             # Service orchestration
├── Caddyfile                      # Reverse proxy config
├── Makefile                       # Build automation
├── index.html                     # Interactive design prototype
├── .env.example                   # Environment template
├── .gitignore
├── LICENSE                        # MIT License
└── README.md
```

---

## iOS App

### Features

- **Journey Management** — Track active and upcoming train journeys with Flighty-inspired hero cards
- **Live Train Tracking** — Real-time MapKit map showing train position with polyline route, station annotations, and animated train dot
- **Station Timeline** — Detailed station-by-station progress with arrival/departure times, platform info, and delay status
- **Journey Detail** — Full journey view with coach composition diagram, booking details, and train amenities
- **Station Information** — Live platform grid, departures board, and station statistics
- **Search** — Full-text search across trains, stations, and PNR numbers via Meilisearch
- **PNR Status** — Check and watch PNR booking status with passenger-level details
- **India Live Map** — Interactive map showing all live train positions across India
- **Home Screen Widgets** — Journey and PNR widgets via WidgetKit
- **Live Activities** — iOS Live Activity for active journeys (Dynamic Island + Lock Screen)
- **Real-Time Updates** — Server-Sent Events (SSE) streaming for live position data

### Screens

| Screen | Description |
|--------|-------------|
| **JourneysScreen** | Home screen with active journey hero card, inline quick actions, upcoming journeys, and live network map |
| **LiveTrackingScreen** | Real-time MapKit route map with station timeline below |
| **JourneyDetailScreen** | Hero section, coach composition diagram, booking details, amenities |
| **StationInfoScreen** | Station code/name hero, platform grid, departures list, stats |
| **SearchScreen** | Unified search with PNR status cards and recent searches |

### Design System

The app uses a custom dark theme inspired by heritage Indian Railways brass fixtures:

| Token | Value | Usage |
|-------|-------|-------|
| `accent` | `#E4A853` | Primary accent (Heritage Brass) |
| `bgPrimary` | `#08080A` | Main background |
| `bgCard` | `#18181C` | Card backgrounds |
| `railGreen` | `#34D399` | On-time / confirmed status |
| `railRed` | `#F87171` | Delayed / waitlist status |
| `railBlue` | `#60A5FA` | Arriving / info status |

**Typography:**
- **Display** — System Serif (New York) for headings
- **Body** — SF Pro for body text
- **Mono** — SF Mono for codes, numbers, times

### iOS Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Apple Developer account (for device deployment)

### Building the iOS App

```bash
# Open in Xcode
open Rail/Rail.xcodeproj

# Or build from command line
cd Rail
xcodebuild -project Rail.xcodeproj \
  -scheme Rail \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

Configure the API base URL in `Rail/Rail/Config/AppConfig.swift`:

```swift
static var baseURL: String {
    #if targetEnvironment(simulator)
    "http://localhost:3001/api/v1"
    #else
    "http://YOUR_SERVER_IP:3001/api/v1"
    #endif
}
```

---

## Backend API

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/health` | Health check |
| **Journeys** | | |
| `GET` | `/api/v1/journeys` | List user journeys |
| `GET` | `/api/v1/journeys/:id` | Get journey detail |
| `POST` | `/api/v1/journeys` | Create a journey |
| `DELETE` | `/api/v1/journeys/:id` | Delete a journey |
| **Trains** | | |
| `GET` | `/api/v1/trains/:number` | Get train info |
| `GET` | `/api/v1/trains/:number/route` | Get train route |
| `GET` | `/api/v1/trains/:number/coach-composition` | Get coach layout |
| `GET` | `/api/v1/trains/:number/live` | SSE live position stream |
| `GET` | `/api/v1/trains/live/all` | All live positions |
| `GET` | `/api/v1/trains/search?q=` | Search trains |
| `GET` | `/api/v1/trains/between?from=&to=` | Trains between stations |
| **Stations** | | |
| `GET` | `/api/v1/stations` | List all stations |
| `GET` | `/api/v1/stations/:code` | Get station info |
| `GET` | `/api/v1/stations/:code/platforms` | Platform status |
| `GET` | `/api/v1/stations/:code/live` | SSE station events |
| `GET` | `/api/v1/stations/search?q=` | Search stations |
| **PNR** | | |
| `GET` | `/api/v1/pnr/:number` | Check PNR status |
| `GET` | `/api/v1/pnr/watched` | List watched PNRs |
| `POST` | `/api/v1/pnr/watch` | Watch a PNR |
| `DELETE` | `/api/v1/pnr/watch/:number` | Unwatch a PNR |
| **Widget** | | |
| `GET` | `/api/v1/widget/journey` | Widget journey data |
| `GET` | `/api/v1/widget/pnr` | Widget PNR data |

### Backend Services

| Module | Purpose |
|--------|---------|
| `StationsModule` | Station CRUD, search, platform status |
| `TrainsModule` | Train info, routes, coach composition, live tracking |
| `JourneysModule` | User journey lifecycle management |
| `PNRModule` | PNR status checking and watchlist |
| `NotificationsModule` | Push notification dispatch |
| `SearchModule` | Meilisearch index management |
| `CacheModule` | Valkey/Redis caching layer |
| `QueueModule` | BullMQ background job processing |
| `WidgetModule` | iOS widget data endpoints |
| `MetricsModule` | API usage metrics |
| `ParseableModule` | Structured logging to Parseable |
| `HealthModule` | Service health checks |

### Queue Processors

| Processor | Purpose |
|-----------|---------|
| `TrainPositionProcessor` | Process incoming live train position events |
| `PNRRefreshProcessor` | Periodically refresh watched PNR statuses |
| `NotificationDispatchProcessor` | Send push notifications to user devices |
| `DataSyncProcessor` | Synchronize data from external sources |

---

## Database

### Schema

The database uses PostgreSQL 16 with the following tables:

| Table | Description |
|-------|-------------|
| `stations` | Railway stations with code, name, zone, lat/lng, amenities |
| `trains` | Train information with number, name, type, schedule |
| `train_routes` | Station stops for each train route |
| `coach_compositions` | Coach layout for each train |
| `users` | User accounts |
| `journeys` | User journey bookings |
| `pnr_watchlist` | Watched PNR numbers |
| `user_devices` | Push notification device tokens |
| `notification_preferences` | User notification settings |

### Migrations

9 sequential migration files in `database/migrations/`:

```
001_create_stations.sql
002_create_trains.sql
003_create_train_routes.sql
004_create_coach_compositions.sql
005_create_users.sql
006_create_journeys.sql
007_create_pnr_watchlist.sql
008_create_user_devices.sql
009_create_notification_preferences.sql
```

### Seeds

4 seed files in `database/seeds/` providing initial data:

```
001_seed_stations.sql        # Indian railway stations
002_seed_trains.sql           # Popular trains
003_seed_train_routes.sql     # Route stops
004_seed_coach_compositions.sql  # Coach layouts
```

---

## Ingestion Worker

The Go ingestion worker (`ingestion/`) polls Indian Railways NTES for real-time train data:

- **Scraper** — Fetches live train positions from NTES API
- **Publisher** — Publishes position events to Parseable streams and updates Valkey cache
- **Mock Generator** — Generates realistic mock data when `MOCK_DATA=true`
- **Configurable** — Poll interval, data source URL, and mock mode via environment variables

```go
// Configuration
NTES_BASE_URL=https://enquiry.indianrail.gov.in
INGESTION_POLL_INTERVAL=60  // seconds
MOCK_DATA=true              // use mock data
```

---

## Infrastructure

### Docker Compose Services

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| `postgres` | postgres:16 | 5432 | Primary database |
| `parseable` | parseable/parseable:latest | 8000 | Log aggregation |
| `valkey` | valkey/valkey:latest | 6379 | Cache (Redis-compatible) |
| `meilisearch` | getmeili/meilisearch:latest | 7700 | Full-text search |
| `api` | Custom (NestJS) | 3001 | REST API server |
| `ingestion` | Custom (Go) | - | Background worker |
| `caddy` | caddy:latest | 80, 443 | Reverse proxy |

### Caddy Configuration

- Reverse proxies `/api/*` to NestJS backend
- Routes `/parseable/*` to Parseable dashboard
- Routes `/search/*` to Meilisearch
- Serves static frontend
- Automatic HTTPS with Let's Encrypt
- Security headers and CORS

---

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Xcode 15+](https://developer.apple.com/xcode/) (for iOS development)
- macOS 14+ (for iOS simulator)

### Quick Start

```bash
# Clone the repository
git clone https://github.com/Debanitrkl/rail-app.git
cd rail-app

# Copy environment file
cp .env.example .env

# Start all services
make up

# Wait for services to be healthy (~30 seconds)
make health

# Run setup scripts (Parseable streams + Meilisearch indexes)
make setup

# Seed the database
make seed
```

The API is now available at `http://localhost:3001/api/v1`.

### Development Setup

```bash
# Start fresh with clean volumes
make fresh

# View all logs
make logs

# View specific service logs
make logs-api
make logs-ingestion

# Restart a specific service
make restart-api
make restart-ingestion

# Run backend tests
make test

# Lint backend code
make lint

# Check service health
make health

# Shell into a container
make shell-api
make shell-postgres
```

### iOS Development

1. Start the backend services:
   ```bash
   make up
   ```

2. Open the iOS project:
   ```bash
   open Rail/Rail.xcodeproj
   ```

3. Select your target device/simulator in Xcode

4. Build and run (Cmd+R)

For device testing, update the API base URL in `Rail/Rail/Config/AppConfig.swift` to your machine's local IP address.

---

## Configuration

All configuration is managed through environment variables. Copy `.env.example` to `.env` and adjust:

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_HOST` | `postgres` | Database host |
| `POSTGRES_PORT` | `5432` | Database port |
| `POSTGRES_USER` | `rail` | Database user |
| `POSTGRES_PASSWORD` | `rail_secret_2024` | Database password |
| `POSTGRES_DB` | `rail` | Database name |
| `PARSEABLE_URL` | `http://parseable:8000` | Parseable endpoint |
| `PARSEABLE_USER` | `admin` | Parseable username |
| `PARSEABLE_PASSWORD` | `admin` | Parseable password |
| `VALKEY_HOST` | `valkey` | Redis-compatible cache host |
| `VALKEY_PORT` | `6379` | Cache port |
| `MEILISEARCH_HOST` | `http://meilisearch:7700` | Search engine host |
| `MEILISEARCH_MASTER_KEY` | `rail_meili_master_key_2024` | Search API key |
| `API_PORT` | `3001` | Backend API port |
| `NODE_ENV` | `production` | Node environment |
| `JWT_SECRET` | `rail_jwt_secret_change_in_production` | JWT signing secret |
| `NTES_BASE_URL` | `https://enquiry.indianrail.gov.in` | Indian Railways API |
| `INGESTION_POLL_INTERVAL` | `60` | Scraper poll interval (seconds) |
| `MOCK_DATA` | `true` | Use mock data instead of NTES |
| `DOMAIN` | `rail.localhost` | Caddy domain |

---

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Start all services |
| `make down` | Stop all services |
| `make build` | Build all containers |
| `make fresh` | Clean rebuild from scratch |
| `make dev` | Start development environment |
| `make logs` | View all service logs |
| `make migrate` | Run database migrations |
| `make seed` | Seed database with sample data |
| `make setup` | Configure Parseable + Meilisearch |
| `make test` | Run backend tests |
| `make lint` | Lint backend code |
| `make health` | Check all service health |
| `make ps` | Show running containers |
| `make clean` | Remove all containers and volumes |
| `make restart-api` | Restart the API server |
| `make restart-ingestion` | Restart the ingestion worker |
| `make shell-{service}` | Shell into a container |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
