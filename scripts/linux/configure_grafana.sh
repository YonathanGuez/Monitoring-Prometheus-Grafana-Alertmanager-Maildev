#!/bin/bash

GRAFANA_URL="http://admin:admin@localhost:3000"  # Update with your Grafana URL
PROMETHEUS_URL="http://prometheus:9090"  # Update with your Prometheus URL
GRAFANA_API_KEY="your_grafana_api_key"  # Replace with your Grafana API key

# Create Prometheus data source JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
  "name": "Prometheus",
  "type": "prometheus",
  "url": "${PROMETHEUS_URL}",
  "access": "proxy",
  "isDefault": true
}
EOF
)

# Add Prometheus data source to Grafana
curl -X POST \
  -H "Authorization: Bearer ${GRAFANA_API_KEY}" \
  -H "Content-Type: application/json" \
  --data-binary "${JSON_PAYLOAD}" \
  "${GRAFANA_URL}/api/datasources"

