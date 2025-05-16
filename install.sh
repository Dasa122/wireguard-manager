#!/bin/bash

WAYBAR_CONFIG_PATH=.config
#$(ps aux | grep 'waybar' | grep -- '--config' | awk -F '--config ' '{print $2}' | awk '{print $1}')

if grep -q '"custom/wireguard-manager"' "$WAYBAR_CONFIG_PATH"; then
    echo "custom/wireguard-manager already exists in config. Exiting."
    exit 0
fi

if [ -n "$WAYBAR_CONFIG_PATH" ]; then
    echo "Waybar config path: $WAYBAR_CONFIG_PATH"

else
    echo "Useing default Waybar config path: ~/.config/waybar/config"
    WAYBAR_CONFIG_PATH=~/.config/waybar/config
fi

    echo "custom/wireguard-manager": { >> "$WAYBAR_CONFIG_PATH"
    echo     "exec": "exec ~/.config/waybar/wireguard-manager/wireguard-manager.sh -s", >> "$WAYBAR_CONFIG_PATH"
    echo     "format": "{icon}", >> "$WAYBAR_CONFIG_PATH"
    echo     "format-icons": { >> "$WAYBAR_CONFIG_PATH"
    echo         "connected": "<span color=\"#50fa7b\">VPN: 🔒</span>", >> "$WAYBAR_CONFIG_PATH"
    echo         "disconnected": "<span color=\"#ff5555\">VPN: 🔓</span>", >> "$WAYBAR_CONFIG_PATH"
    echo     }, >> "$WAYBAR_CONFIG_PATH"
    echo     "interval": "once", >> "$WAYBAR_CONFIG_PATH"
    echo     "on-click": "~/.config/waybar/wireguard-manager/wireguard-manager.sh -t && pkill -SIGRTMIN+1 waybar", >> "$WAYBAR_CONFIG_PATH"
    echo     "return-type": "json", >> "$WAYBAR_CONFIG_PATH"
    echo     "signal": 1, >> "$WAYBAR_CONFIG_PATH"
    echo } >> "$WAYBAR_CONFIG_PATH"

    sed -i '/"modules-right": \[/a\        "custom/wireguard-manager",' "$WAYBAR_CONFIG_PATH"

