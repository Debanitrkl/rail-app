.PHONY: up down build dev logs migrate seed setup-parseable setup-meilisearch clean test

# Start all services
up:
	docker compose up -d

# Stop all services
down:
	docker compose down

# Build all containers
build:
	docker compose build

# Start development environment
dev:
	bash scripts/dev.sh

# View logs for all services
logs:
	docker compose logs -f

# View logs for specific service
logs-%:
	docker compose logs -f $*

# Run database migrations
migrate:
	bash scripts/migrate.sh

# Seed the database
seed:
	bash scripts/seed.sh

# Setup Parseable streams
setup-parseable:
	bash scripts/setup-parseable.sh

# Setup Meilisearch indexes
setup-meilisearch:
	bash scripts/setup-meilisearch.sh

# Run all setup scripts
setup: setup-parseable setup-meilisearch

# Clean up volumes and containers
clean:
	docker compose down -v --remove-orphans

# Build and start fresh
fresh: clean build up
	sleep 15
	$(MAKE) setup

# Restart the API server
restart-api:
	docker compose restart api

# Restart the ingestion worker
restart-ingestion:
	docker compose restart ingestion

# Run backend tests
test:
	cd backend && npm test

# Lint backend code
lint:
	cd backend && npm run lint

# Build backend only
build-api:
	cd backend && npm run build

# Shell into a container
shell-%:
	docker compose exec $* sh

# Check service health
health:
	@echo "=== Service Health ==="
	@echo -n "API:         " && curl -s http://localhost:3001/api/v1/health | python3 -m json.tool 2>/dev/null || echo "DOWN"
	@echo -n "Parseable:   " && curl -s http://localhost:8000/api/v1/liveness 2>/dev/null || echo "DOWN"
	@echo -n "Meilisearch: " && curl -s http://localhost:7700/health 2>/dev/null || echo "DOWN"
	@echo -n "Valkey:      " && docker compose exec -T valkey valkey-cli ping 2>/dev/null || echo "DOWN"

# Show running containers
ps:
	docker compose ps
