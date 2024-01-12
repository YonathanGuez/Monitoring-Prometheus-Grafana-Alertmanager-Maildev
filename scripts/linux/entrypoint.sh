#!/bin/sh

# Function to check if Grafana is up
grafana_is_up() {
    curl -sI http://localhost:3000 >/dev/null
}

# Poll Grafana availability with a timeout of 300 seconds
timeout=300
while [ $timeout -gt 0 ]; do
    if grafana_is_up; then
        break
    else
        echo "Waiting for Grafana to be up..."
        sleep 5
        timeout=$((timeout - 5))
    fi
done

# Proceed with your actual commands once Grafana is up
if grafana_is_up; then
    echo "Grafana is up! Proceeding with the script..."
    echo 'hello test'
    /tmp/grafana/create-dashboard-api.sh /tmp/grafana/dashboard.json &
else
    echo "Timeout reached. Grafana might not be up. Exiting..."
    exit 1
fi
