#!/bin/bash

# Create config directory if it doesn't exist
CONFIG_DIR="$(dirname "$0")/../config"

# Detect base directory (one levels up from the script)
BASE_DIR="$(realpath "$(dirname "$0")/../")"

# Prompt for configuration
read -p "Enter the protocol for the file server (HTTP/NFS): " FILE_SERVER_PROTOCOL
FILE_SERVER_PROTOCOL=${FILE_SERVER_PROTOCOL:-http}

read -p "Enter IP address of the server that serves this repo: " FILE_SERVER_IP
FILE_SERVER_IP=${FILE_SERVER_IP:-192.168.1.3}

read -p "Enter the path where this repo is served: " FILE_BASE_PATH
FILE_BASE_PATH=${FILE_BASE_PATH:-/srv/pxe}

# Create env.conf file
cat > "$CONFIG_DIR/env.conf" << EOF
#This file houses the enviourment config for all of the scripts
#You can edit this file directly or use setup-env.sh(for easyier config,or to make the file for the first time)

# Base directory configuration
# This is the root directory where all PXE-related files are stored
BASE_DIR=$BASE_DIR

# File Server Configuration
SERVER_PROTOCOL=$FILE_SERVER_PROTOCOL
SERVER_IPv4=$FILE_SERVER_IP
SERVER_BASE_PATH=$FILE_BASE_PATH
EOF


echo "Environment configuration file created at $CONFIG_DIR/env.conf"