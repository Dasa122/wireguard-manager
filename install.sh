#!/bin/bash

#The install script is made by Dasa122, who drinks too much coffee and talks about penguins

# Channel your inner Sherlock Holmes to deduce where this script lives
WG_MANAGER_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find the Waybar config path by stalking the waybar process like a ninja
WAYBAR_CONFIG_PATH=$(ps aux | grep 'waybar' | grep -- '--config' | awk -F '--config ' '{print $2}' | awk '{print $1}')

# Check if our module is already in the config (no double dipping!)
if grep -q '"custom/wireguard-manager"' "$WAYBAR_CONFIG_PATH"; then
    echo "custom/wireguard-manager already exists in config. Exiting."
    exit 1
fi

# Check if the WireGuard manager script exists in the directory
if [ ! -f "$WG_MANAGER_SCRIPT/wireguard-manager.sh" ]; then
    echo "wireguard-manager.sh not found in $WG_MANAGER_SCRIPT. Please make sure it exists."
    exit 1
fi

# If we found the config path, great! Otherwise, let's guess and hope for the best
if [ -n "$WAYBAR_CONFIG_PATH" ] && [ -f "$WAYBAR_CONFIG_PATH" ]; then
    echo "Waybar config path: $WAYBAR_CONFIG_PATH"
elif [ -f "$HOME/.config/waybar/config.jsonc" ]; then
    echo "Using default Waybar config path: $HOME/.config/waybar/config.jsonc"
    WAYBAR_CONFIG_PATH="$HOME/.config/waybar/config.jsonc"
else
    echo "Waybar config path not found. Please set the WAYBAR_CONFIG_PATH variable."
    echo "Exiting."
    exit 1
    # Check if var.conf exists and contains WAYBAR_CONFIG_PATH
    if [ -f "$HOME/.config/hypr/waybar/wireguard-manager/var.conf" ]; then
        source "$HOME/.config/hypr/waybar/wireguard-manager/var.conf"
        if [ -n "$WAYBAR_CONFIG_PATH" ] && [ -f "$WAYBAR_CONFIG_PATH" ]; then
            echo "Using WAYBAR_CONFIG_PATH from var.conf: $WAYBAR_CONFIG_PATH"
        else
            echo "WAYBAR_CONFIG_PATH not set or file does not exist in var.conf. Exiting."
            exit 1
        fi
    else
        echo "var.conf not found. Please set the WAYBAR_CONFIG_PATH variable."
        exit 1
    fi
fi

# Inject our WireGuard manager module into the config like a secret agent
cat <<EOF >> "$WAYBAR_CONFIG_PATH"
"custom/wireguard-manager": {
    "exec": "exec $WG_MANAGER_SCRIPT -s",
    "format": "{icon}",
    "format-icons": {
        "connected": "<span color=\"#50fa7b\">VPN: 🔒</span>",
        "disconnected": "<span color=\"#ff5555\">VPN: 🔓</span>",
    },
    "interval": "once",
    "on-click": "$WG_MANAGER_SCRIPT -t && pkill -SIGRTMIN+1 waybar",
    "return-type": "json",
    "signal": 1,
}
EOF
echo "Added custom/wireguard-manager to Waybar config."

# Ask the user where to put the module (left, right, or center—choose wisely!)
read -p "Where do you want to place the WireGuard manager module? (left/right/center): " position

case "$position" in
    left)
        sed -i '/"modules-left": \[/a\        "custom/wireguard-manager",' "$WAYBAR_CONFIG_PATH"
        ;;
    right)
        sed -i '/"modules-right": \[/a\        "custom/wireguard-manager",' "$WAYBAR_CONFIG_PATH"
        ;;
    center)
        sed -i '/"modules-center": \[/a\        "custom/wireguard-manager",' "$WAYBAR_CONFIG_PATH"
        ;;
    *)
        echo "Invalid position. Please choose left, right, or center."
        exit 1
        ;;
esac
