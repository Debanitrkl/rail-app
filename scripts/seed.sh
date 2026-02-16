#!/bin/bash
set -e

POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_USER="${POSTGRES_USER:-rail}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-rail_secret_2024}"
POSTGRES_DB="${POSTGRES_DB:-rail}"

export PGPASSWORD="${POSTGRES_PASSWORD}"

echo "Seeding database..."

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL..."
for i in $(seq 1 30); do
    if pg_isready -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" > /dev/null 2>&1; then
        echo "PostgreSQL is ready"
        break
    fi
    echo "  Attempt $i/30..."
    sleep 2
done

SEEDS_DIR="$(dirname "$0")/../database/seeds"

for f in "${SEEDS_DIR}"/*.sql; do
    if [ -f "$f" ]; then
        echo "Running seed: $(basename "$f")"
        psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -f "$f"
    fi
done

echo "Seeding complete!"
