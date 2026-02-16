#!/bin/bash
set -e

echo "Running Rail database initialization..."

# Run migrations in order
for f in /docker-entrypoint-initdb.d/migrations/*.sql; do
  if [ -f "$f" ]; then
    echo "Running migration: $f"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$f"
  fi
done

# Run seeds in order
for f in /docker-entrypoint-initdb.d/seeds/*.sql; do
  if [ -f "$f" ]; then
    echo "Running seed: $f"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$f"
  fi
done

echo "Database initialization complete."
