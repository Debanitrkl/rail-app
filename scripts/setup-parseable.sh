#!/bin/bash
set -e

PARSEABLE_URL="${PARSEABLE_URL:-http://localhost:8000}"
PARSEABLE_USER="${PARSEABLE_USER:-admin}"
PARSEABLE_PASSWORD="${PARSEABLE_PASSWORD:-admin}"

AUTH=$(echo -n "${PARSEABLE_USER}:${PARSEABLE_PASSWORD}" | base64)

echo "Setting up Parseable streams..."

# Wait for Parseable to be ready
echo "Waiting for Parseable..."
for i in $(seq 1 30); do
    if curl -s "${PARSEABLE_URL}/api/v1/liveness" > /dev/null 2>&1; then
        echo "Parseable is ready"
        break
    fi
    echo "  Attempt $i/30..."
    sleep 2
done

create_stream() {
    local stream_name=$1
    echo "Creating stream: ${stream_name}"

    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -X PUT "${PARSEABLE_URL}/api/v1/logstream/${stream_name}" \
        -H "Authorization: Basic ${AUTH}" \
        -H "Content-Type: application/json")

    if [ "$response" = "200" ]; then
        echo "  Stream '${stream_name}' created successfully"
    elif [ "$response" = "409" ]; then
        echo "  Stream '${stream_name}' already exists"
    else
        echo "  Warning: Unexpected status ${response} for stream '${stream_name}'"
    fi
}

# Create data streams
echo ""
echo "--- Data Streams ---"
create_stream "train-positions"
create_stream "platform-changes"
create_stream "delay-events"
create_stream "pnr-status-changes"

# Create monitoring/observability streams
echo ""
echo "--- Monitoring Streams ---"
create_stream "app-logs"
create_stream "api-metrics"
create_stream "worker-logs"
create_stream "system-events"

echo ""
echo "Parseable setup complete!"
echo ""
echo "Data streams:"
echo "  train-positions:     train_number, latitude, longitude, speed_kmph, delay_minutes, current_station, next_station, eta_next, timestamp"
echo "  platform-changes:    station_code, platform_number, train_number, event_type, timestamp"
echo "  delay-events:        train_number, station_code, scheduled_time, actual_time, delay_minutes, cause, timestamp"
echo "  pnr-status-changes:  pnr, old_status, new_status, coach, berth, timestamp"
echo ""
echo "Monitoring streams:"
echo "  app-logs:            service, level, message, context, trace_id, timestamp"
echo "  api-metrics:         method, path, status_code, duration_ms, user_agent, timestamp"
echo "  worker-logs:         worker, job, level, message, duration_ms, timestamp"
echo "  system-events:       service, event, details, timestamp"
