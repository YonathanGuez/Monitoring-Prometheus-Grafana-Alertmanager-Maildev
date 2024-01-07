# PowerShell Script for Automation - Configuration of Prometheus YAML

# Get local IP address using Get-NetIPAddress
$localIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Wi-Fi').IPAddress

# Debugging line: Display the obtained local IP
Write-Output "Obtained local IP: $localIP"

if (-not [string]::IsNullOrEmpty($localIP)) {
    # Define the content for the YAML file
    $yamlContent = @"
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: MyIP
    static_configs:
      - targets: ['$($localIP):9182']
"@

    $CurrentDirectory = $PWD.Path
    Write-Output "Current directory path: $CurrentDirectory"
    # Specify the path for the YAML file
    $yamlFilePath = "$CurrentDirectory\prometheus-IP.yml"

    # Write the content to the YAML file
    $yamlContent | Out-File -FilePath $yamlFilePath -Encoding UTF8

    # Display a message
    Write-Output "YAML file created at: $yamlFilePath"
} else {
    Write-Output "Error: Unable to obtain a valid local IP address."
}
