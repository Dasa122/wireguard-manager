#!/bin/bash

WAYBAR_CONFIG_PATH=$(ps aux | grep 'waybar' | grep -- '--config' | awk -F '--config ' '{print $2}' | awk '{print $1}')

if [ -n "$WAYBAR_CONFIG_PATH" ]; then
    echo "Waybar config path: $WAYBAR_CONFIG_PATH"
else
    echo "Waybar config path not found."
fi