#!/bin/bash

#The install script is made by Dasa122, who drinks too much coffee and talks about penguins
set -e
echo "Installing WireGuard manager module for Waybar..."
# Channel your inner Sherlock Holmes to find where this script lives
WG_MANAGER_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find the Waybar config path by stalking the waybar process like a ninja
WAYBAR_CONFIG_PATH=$(ps aux | grep 'waybar' | grep -- '--config' | awk -F '--config ' '{print $2}' | awk '{print $1}')

echo "If you encounter any issues, please open an issue on GitHub."
# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[31merror: This script must be run as root. Please use sudo (or ask your cat for admin rights).\033[0m" >&2
    exit 1
fi



# Summon the ancient spirits to check if the WireGuard manager script exists in the directory
# (Or, you know, just look for the file like a normal person)
if [ ! -f "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh" ]; then
    echo -e "\033[31merror: wireguard-manager.sh not found in $WG_MANAGER_SCRIPT_DIR. Please make sure it exists.\033[0m" >&2
    exit 1
fi

# If we found the config path, great! Otherwise, let's guess and hope for the best
if [ -n "$WAYBAR_CONFIG_PATH" ] && [ -f "$WAYBAR_CONFIG_PATH" ]; then
    echo "Waybar config path: $WAYBAR_CONFIG_PATH"
elif [ -f "$HOME/.config/waybar/config.jsonc" ]; then
    echo "Using default Waybar config path: $HOME/.config/waybar/config.jsonc"
    WAYBAR_CONFIG_PATH="$HOME/.config/waybar/config.jsonc"
else
    echo -e "\033[31merror: Waybar config path not found. Please set the WAYBAR_CONFIG_PATH variable in the install script.\033[0m" >&2
    exit 1
fi

# Check if the Waybar config file is writable like a true artist
if [ ! -w "$WAYBAR_CONFIG_PATH" ]; then
    echo -e "\033[31merror: Waybar config file is not writable. Please check your permissions.\033[0m" >&2
    exit 1
fi

# Like a sneaky ninja, insert WIREGUARD_MANAGER_SCRIPT_PATH at the top of wireguard-manager.sh if it's not already seaking there
if grep -q '^WG_MANAGER_SCRIPT_DIR=' "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh"; then
    sed -i "s|^WG_MANAGER_SCRIPT_DIR=.*|WG_MANAGER_SCRIPT_DIR=\"$WG_MANAGER_SCRIPT_DIR\"|" "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh"
else
    sed -i "2iWG_MANAGER_SCRIPT_DIR=\"$WG_MANAGER_SCRIPT_DIR\"" "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh"
fi

# Prompt the user for the WireGuard service name
read -p "Enter your WireGuard service name (e.g., wg0): " wg_service_name

# Check if the service exists
if [ ! -f "/etc/wireguard/${wg_service_name}.conf" ]; then
    echo -e "\033[31merror: /etc/wireguard/${wg_service_name}.conf not found. Please check your WireGuard configuration.\033[0m" >&2
    exit 1
else
    echo "WireGuard configuration found: /etc/wireguard/${wg_service_name}.conf"
fi

# Insert or update the WG_SERVICE_NAME variable at the top of wireguard-manager.sh
if grep -q '^WG_SERVICE_NAME=' "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh"; then
    sed -i "s|^WG_SERVICE_NAME=.*|WG_SERVICE_NAME=\"wg-quick@$wg_service_name\"|" "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh"
else
    sed -i "2iWG_SERVICE_NAME=\"wg-quick@$wg_service_name\"" "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh"
fi

# Prompt the user to choose light or dark rofi config
read -p "Choose your rofi theme (light/dark): " rofi_theme

case "$rofi_theme" in
    light)
        ROFI_CONFIG="$WG_MANAGER_SCRIPT_DIR/rofi-light.rasi"
        ;;
    dark)
        ROFI_CONFIG="$WG_MANAGER_SCRIPT_DIR/rofi-dark.rasi"
        ;;
    *)
        echo -e "\033[31merror: Invalid theme. Please choose light or dark.\033[0m" >&2
        exit 1
        ;;
esac

# Save the chosen rofi config path to wireguard-manager.sh
if grep -q '^ROFI_CONFIG=' "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh"; then
    sed -i "s|^ROFI_CONFIG=.*|ROFI_CONFIG=\"$ROFI_CONFIG\"|" "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh"
else
    sed -i "2iROFI_CONFIG=\"$ROFI_CONFIG\"" "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh"
fi

# Check if our module is already in the config like a nosy neighbor
if grep -q '"custom/wireguard-manager"' "$WAYBAR_CONFIG_PATH"; then
    echo -e "\033[31merror: custom/wireguard-manager already exists in config. Exiting.\033[0m" >&2
    exit 1
fi

# Inject our WireGuard manager module into the config like a secret agent
cat <<EOF >> "$WAYBAR_CONFIG_PATH"


"custom/wireguard-manager": {
    "exec": "exec $WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh -s",
    "format": "{icon}",
    "format-icons": {
        "connected": "<span color=\"#50fa7b\">VPN: 🔒</span>",
        "disconnected": "<span color=\"#ff5555\">VPN: 🔓</span>",
    },
    "interval": "once",
    "on-click": "$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh -t && pkill -SIGRTMIN+1 waybar",
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
        echo -e "\033[31merror: Invalid position. Please choose left, right, or center.\033[0m" >&2
        exit 1
        ;;
esac



echo "WireGuard manager module installed successfully!"
echo "Please restart Waybar to see the changes."
echo "If you encounter any issues, please open an issue on GitHub."