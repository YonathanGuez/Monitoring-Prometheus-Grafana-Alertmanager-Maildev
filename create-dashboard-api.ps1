# Check if the path to the JSON file is provided as a parameter
if ($args.Length -eq 0) {
  Write-Host "Usage: $scriptName <path_to_dashboard_json>"
  exit 1
}

$dashboardJsonFile = $args[0]

# Step 1: Create Organization
$orgResponse = Invoke-RestMethod -Uri 'http://admin:admin@localhost:3000/api/orgs' -Method Post -Headers @{"Content-Type"="application/json"} -Body '{"name":"apiorg"}'
$orgId = $orgResponse.orgId

# Step 2: Switch org context
Invoke-RestMethod -Uri "http://admin:admin@localhost:3000/api/user/using/$orgId" -Method Post

# Step 3: Create Service Account
$saResponse = Invoke-RestMethod -Uri 'http://admin:admin@localhost:3000/api/serviceaccounts' -Method Post -Headers @{"Content-Type"="application/json"} -Body '{"name":"test", "role": "Admin"}'
$saId = $saResponse.id

# Step 4: Create Service Account token
$tokenResponse = Invoke-RestMethod -Uri "http://admin:admin@localhost:3000/api/serviceaccounts/$saId/tokens" -Method Post -Headers @{"Content-Type"="application/json"} -Body '{"name":"test-token"}'
$tokenKey = $tokenResponse.key

# Step 5: Create the Dashboard from JSON File
$keyTokenApi = $tokenKey  # Replace with the actual API key
$dashboardContent = Get-Content $dashboardJsonFile | Out-String

Invoke-RestMethod -Uri 'http://localhost:3000/api/dashboards/db' -Method Post -Headers @{"Authorization"="Bearer $keyTokenApi"; "Content-Type"="application/json"} -Insecure -Body $dashboardContent
