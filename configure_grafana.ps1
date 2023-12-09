# Configuration
$grafanaUrl = "http://admin:admin@localhost:3000"  # Update with your Grafana URL
$prometheusUrl = "http://prometheus:9090"  # Update with your Prometheus URL
$grafanaApiKey = "your_grafana_api_key"  # Replace with your Grafana API key

# Create Prometheus data source JSON payload
$jsonPayload = @"
{
  "name": "Prometheus",
  "type": "prometheus",
  "url": "$prometheusUrl",
  "access": "proxy",
  "isDefault": true
}
"@

# Add Prometheus data source to Grafana
$headers = @{
    "Authorization" = "Bearer $grafanaApiKey"
    "Content-Type"  = "application/json"
}

$response = Invoke-RestMethod -Uri "$grafanaUrl/api/datasources" -Method Post -Headers $headers -Body $jsonPayload

# Output the response (can be useful for debugging)
Write-Output $response
