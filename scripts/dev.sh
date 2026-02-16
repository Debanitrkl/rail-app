#!/bin/bash
set -e

echo "==================================="
echo "  Rail - Development Environment"
echo "==================================="
echo ""

PROJECT_DIR="$(dirname "$0")/.."
cd "${PROJECT_DIR}"

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "Step 1: Starting infrastructure services..."
docker compose up -d postgres valkey parseable meilisearch

echo ""
echo "Step 2: Waiting for services to be healthy..."
sleep 10

# Wait for PostgreSQL
echo "  Waiting for PostgreSQL..."
for i in $(seq 1 30); do
    if docker compose exec -T postgres pg_isready -U rail > /dev/null 2>&1; then
        echo "  PostgreSQL is ready"
        break
    fi
    if [ "$i" = "30" ]; then echo "  WARNING: PostgreSQL timeout, continuing anyway..."; fi
    sleep 2
done

# Wait for Parseable
echo "  Waiting for Parseable..."
for i in $(seq 1 30); do
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8000/api/v1/liveness" 2>/dev/null | grep -q "200"; then
        echo "  Parseable is ready"
        break
    fi
    if [ "$i" = "30" ]; then echo "  WARNING: Parseable timeout, continuing anyway..."; fi
    sleep 2
done

# Wait for Meilisearch
echo "  Waiting for Meilisearch..."
for i in $(seq 1 30); do
    if curl -s "http://localhost:7700/health" 2>/dev/null | grep -q "available"; then
        echo "  Meilisearch is ready"
        break
    fi
    if [ "$i" = "30" ]; then echo "  WARNING: Meilisearch timeout, continuing anyway..."; fi
    sleep 2
done

echo ""
echo "Step 3: Setting up Parseable streams..."
bash scripts/setup-parseable.sh

echo ""
echo "Step 4: Setting up Meilisearch indexes..."
bash scripts/setup-meilisearch.sh

echo ""
echo "Step 5: Building and starting API server..."
docker compose up -d api

echo ""
echo "Step 6: Starting ingestion worker..."
docker compose up -d ingestion

echo ""
echo "Step 7: Starting Caddy reverse proxy..."
docker compose up -d caddy

echo ""
echo "==================================="
echo "  All services are running!"
echo "==================================="
echo ""
echo "  API Server:    http://localhost:3001"
echo "  API Docs:      http://localhost:3001/api/docs"
echo "  Parseable:     http://localhost:8000  (data + monitoring)"
echo "  Meilisearch:   http://localhost:7700"
echo "  Reverse Proxy: http://localhost:80"
echo ""
echo "  To view logs:  docker compose logs -f"
echo "  To stop:       docker compose down"
echo ""
