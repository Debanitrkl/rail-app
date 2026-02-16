#!/bin/bash
set -e

MEILISEARCH_HOST="${MEILISEARCH_HOST:-http://localhost:7700}"
MEILISEARCH_MASTER_KEY="${MEILISEARCH_MASTER_KEY:-rail_meili_master_key_2024}"

echo "Setting up Meilisearch indexes..."

# Wait for Meilisearch to be ready
echo "Waiting for Meilisearch..."
for i in $(seq 1 30); do
    if curl -s "${MEILISEARCH_HOST}/health" | grep -q "available"; then
        echo "Meilisearch is ready"
        break
    fi
    echo "  Attempt $i/30..."
    sleep 2
done

# Create stations index
echo "Creating stations index..."
curl -s -X POST "${MEILISEARCH_HOST}/indexes" \
    -H "Authorization: Bearer ${MEILISEARCH_MASTER_KEY}" \
    -H "Content-Type: application/json" \
    -d '{"uid": "stations", "primaryKey": "code"}' | python3 -m json.tool 2>/dev/null || true

# Configure stations index settings
echo "Configuring stations index..."
curl -s -X PATCH "${MEILISEARCH_HOST}/indexes/stations/settings" \
    -H "Authorization: Bearer ${MEILISEARCH_MASTER_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
        "searchableAttributes": ["name", "code", "zone", "state", "searchText"],
        "filterableAttributes": ["zone", "state"],
        "sortableAttributes": ["name"],
        "typoTolerance": {
            "enabled": true,
            "minWordSizeForTypos": {
                "oneTypo": 3,
                "twoTypos": 6
            }
        }
    }' | python3 -m json.tool 2>/dev/null || true

# Create trains index
echo "Creating trains index..."
curl -s -X POST "${MEILISEARCH_HOST}/indexes" \
    -H "Authorization: Bearer ${MEILISEARCH_MASTER_KEY}" \
    -H "Content-Type: application/json" \
    -d '{"uid": "trains", "primaryKey": "number"}' | python3 -m json.tool 2>/dev/null || true

# Configure trains index settings
echo "Configuring trains index..."
curl -s -X PATCH "${MEILISEARCH_HOST}/indexes/trains/settings" \
    -H "Authorization: Bearer ${MEILISEARCH_MASTER_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
        "searchableAttributes": ["name", "number", "type", "sourceStation", "destinationStation", "searchText"],
        "filterableAttributes": ["type"],
        "sortableAttributes": ["name", "number"],
        "typoTolerance": {
            "enabled": true,
            "minWordSizeForTypos": {
                "oneTypo": 3,
                "twoTypos": 6
            }
        }
    }' | python3 -m json.tool 2>/dev/null || true

echo ""
echo "Meilisearch setup complete!"
echo "  - stations index (primary key: code)"
echo "  - trains index (primary key: number)"
echo ""
echo "Note: The NestJS API server will sync data from PostgreSQL to Meilisearch on startup."
