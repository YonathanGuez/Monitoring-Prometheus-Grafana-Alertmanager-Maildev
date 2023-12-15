#!/bin/bash

# Bash Script for Automation - Configuration of Prometheus YAML

# Get local IP address using ifconfig (assuming 'Ethernet' is the network interface)
localIP=$(ifconfig Ethernet | grep -oP 'inet addr:\K\S+' | head -n 1)

# Debugging line: Display the obtained local IP
echo "Obtained local IP: $localIP"

if [ -n "$localIP" ]; then
    # Define the content for the YAML file
    yamlContent=$(cat <<EOF
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: MyIP
    static_configs:
      - targets: ['$localIP:9182']
EOF
)

    currentDirectory=$(pwd)
    echo "Current directory path: $currentDirectory"
    # Specify the path for the YAML file
    yamlFilePath="$currentDirectory/prometheus-IP.yml"

    # Write the content to the YAML file
    echo "$yamlContent" > "$yamlFilePath"

    # Display a message
    echo "YAML file created at: $yamlFilePath"
else
    echo "Error: Unable to obtain a valid local IP address."
fi

