#!/bin/bash

DEFAULT_CONFIG="/opt/nautobot/nautobot_config.py"
CUSTOM_CONFIG="/opt/nautobot/config/nautobot_config.py"

# Check if the default configuration exists
if [ ! -f "$DEFAULT_CONFIG" ]; then
    echo "Default configuration file not found. Initializing Nautobot..."
    nautobot-server init
fi

# Check if the custom configuration exists
if [ ! -f "$CUSTOM_CONFIG" ]; then
    echo "Custom configuration file not found. Copying default configuration to $CUSTOM_CONFIG..."
    mkdir -p "$(dirname "$CUSTOM_CONFIG")"
    cp "$DEFAULT_CONFIG" "$CUSTOM_CONFIG"
fi

# Set the NAUTOBOT_CONFIG environment variable
export NAUTOBOT_CONFIG="$CUSTOM_CONFIG"

# Pass control to the CMD
exec "$@"