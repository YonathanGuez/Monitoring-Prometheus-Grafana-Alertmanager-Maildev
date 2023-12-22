# Check if the path to the JSON file is provided as a parameter
if ($args.Length -eq 0) {
  Write-Host "Usage: $scriptName <path_to_dashboard_json>"
  exit 1
}

$dashboardJsonFile = $args[0]

# Replace 'your_admin_username' and 'your_admin_password' with valid Grafana credentials
$adminUsername = 'admin'
$adminPassword = 'admin'

# Base64 encode the credentials
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$adminUsername"+":"+"$adminPassword"))

# Set the Grafana API endpoint
$apiUrl = 'http://localhost:3000/api/orgs'

# Define the organization name
$orgName = 'apiorg4'

# Create headers with the authorization information
$headers = @{
    Authorization = "Basic $base64AuthInfo"
    'Content-Type' = 'application/json'
}

# Create the body of the request
$body = @{
    name = $orgName
} | ConvertTo-Json

# Make the REST API call to create the organization
try {
    # Make the REST API call to create the organization
    $orgResponse = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body

    # Extract orgId from the response
    $orgId = $orgResponse.orgId
    Write-Output "Organization ID: $orgId"
}
catch {
    Write-Host "Failed step1 to create organization. Error: $($_.Exception.Message)"
    exit 1
}

# Step 2: Switch org context
try {
    Invoke-RestMethod -Uri "http://localhost:3000/api/user/using/$orgId" -Method Post -Headers $headers
}
catch {
    Write-Host "Failed step2 to switch organization context. Error: $($_.Exception.Message)"
    exit 1
}

# Step 3: Create Service Account
try {
    # Create the body of the request
    $body2 = @{
        name = "test"
        role = "Admin"
    } | ConvertTo-Json
    $saResponse = Invoke-RestMethod -Uri 'http://localhost:3000/api/serviceaccounts' -Method Post -Headers $headers -Body $body2 
    $saId = $saResponse.id
}
catch {
    Write-Host "Failed step3 to create service account. Error: $($_.Exception.Message)"
    exit 1
}

# Step 4: Create Service Account token
try {
    $tokenResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/serviceaccounts/$saId/tokens" -Method Post -Headers $headers -Body '{"name":"test-token"}'
    $tokenKey = $tokenResponse.key
}
catch {
    Write-Host "Failed step4 to create service account token. Error: $($_.Exception.Message)"
    exit 1
}

# Step 5: Create the Dashboard from JSON File
$keyTokenApi = $tokenKey  # Replace with the actual API key
$dashboardContent = Get-Content $dashboardJsonFile | Out-String

try {
    Invoke-RestMethod -Uri 'http://localhost:3000/api/dashboards/db' -Method Post -Headers @{"Authorization"="Bearer $keyTokenApi"; "Content-Type"="application/json"} -Insecure -Body $dashboardContent 
    Write-Output "Dashboard creation successful."
}
catch {
    Write-Host "Failed step5 to create dashboard. Error: $($_.Exception.Message)"
    exit 1
}
