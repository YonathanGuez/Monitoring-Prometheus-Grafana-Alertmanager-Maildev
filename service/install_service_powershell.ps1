# Path to your PowerShell scripts

$CurrentDirectory = $PWD.Path
Write-Output "Current directory path: $CurrentDirectory"

# Define service parameters
$serviceName = "DockerService"
$displayName = "Docker Daemon Service"
$description = "Manages the Docker daemon as a Windows service"
$startScript = Join-Path -Path $CurrentDirectory -ChildPath "start_service-docker.ps1"
$stopScript = Join-Path -Path $CurrentDirectory -ChildPath "stop_service-docker.ps1"

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an administrator."
    $arguments = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    Exit
}


# Install the service
New-Service -Name $serviceName -DisplayName $displayName -Description $description -BinaryPathName "powershell.exe -ExecutionPolicy Bypass -File $startScript" -StartupType Automatic