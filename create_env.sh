#!/bin/bash

# Get the IPv4 address
COMPUTER_IP=$( ifconfig | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' | head -n 1)

# Write to .env file
echo "COMPUTER_IP=$COMPUTER_IP" > .env

echo ".env file created with COMPUTER_IP=$COMPUTER_IP"

