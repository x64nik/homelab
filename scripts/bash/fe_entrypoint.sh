#!/bin/sh

# This script will replace placeholders in config.json with environment variables that exist in config.json

echo "Replacing placeholders in config.json with environment variables..."

CONFIG_PATH="<path to config>.json"

# Loop through all environment variables
for var in $(env | cut -d= -f1); do
  # Check if the variable is mentioned in config.json
  if grep -q "__${var}__" $CONFIG_PATH; then
    # Get the value of the environment variable
    value=$(printenv "$var")
    
    # If the value is not empty, replace the placeholder
    if [[ -n "$value" ]]; then
      echo "Replacing __${var}__ with ${value}"
      sed -i "s|__${var}__|${value}|g" $CONFIG_PATH
    fi
  fi
done

# Start NGINX server
echo "Starting NGINX..."
exec nginx -g 'daemon off;'
