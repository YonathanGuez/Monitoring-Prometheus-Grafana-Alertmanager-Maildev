#!/bin/bash

# Check if the path to the JSON file is provided as a parameter
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_dashboard_json>"
  exit 1
fi

DASHBOARD_JSON_FILE="$1"

# Step 1: Create Organization
ORG_RESPONSE=$(curl -X POST -H "Content-Type: application/json" -d '{"name":"apiorg"}' http://admin:admin@localhost:3000/api/orgs)
ORG_ID=$(echo $ORG_RESPONSE | jq -r '.orgId')

# Step 2: Switch org context
curl -X POST http://admin:admin@localhost:3000/api/user/using/$ORG_ID

# Step 3: Create Service Account
SA_RESPONSE=$(curl -X POST -H "Content-Type: application/json" -d '{"name":"test", "role": "Admin"}' http://admin:admin@localhost:3000/api/serviceaccounts)
SA_ID=$(echo $SA_RESPONSE | jq -r '.id')

# Step 4: Create Service Account token
TOKEN_RESPONSE=$(curl -X POST -H "Content-Type: application/json" -d '{"name":"test-token"}' http://admin:admin@localhost:3000/api/serviceaccounts/$SA_ID/tokens)
KEY_TOKEN_API=$(echo $TOKEN_RESPONSE | jq -r '.key')

# Step 5: Add Datasource from JSON File
DATASOURCE=$(cat ./grafana/datasource-prometheus.json)
curl -X POST --insecure -H "Authorization: Bearer $KEY_TOKEN_API" -H "Content-Type: application/json" -d "$DATASOURCE" http://localhost:3000/api/datasources

# Step 6: Create the Dashboard from JSON File

DASHBOARD_CONTENT=$(cat $DASHBOARD_JSON_FILE)

curl -X POST --insecure -H "Authorization: Bearer $KEY_TOKEN_API" -H "Content-Type: application/json" -d "$DASHBOARD_CONTENT" http://localhost:3000/api/dashboards/db
