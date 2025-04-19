#!/bin/bash

# Directory containing the builder scripts
CONFIG_FILE="$(dirname "$0")/../../config/env.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: env configuration file not found at $CONFIG_FILE"
    echo "Run setup-env.sh to create it"
    exit 1
fi
BUILDERS_DIR="$BASE_DIR/builders"

# Iterate over all scripts in the builders directory
for script in "$BUILDERS_DIR"/*.sh; do
    if [ -x "$script" ]; then
        echo "Running $script..."
        "$script"
    else
        echo "Skipping $script (not executable)"
    fi
done