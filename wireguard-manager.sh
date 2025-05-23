#!/usr/bin/env bash
ROFI_CONFIG="/home/dasa122/.config/hypr/waybar/wireguard-manager/rofi-dark.rasi"
WG_SERVICE_NAME="wg-quick@wg0"
WG_MANAGER_SCRIPT_DIR="/home/dasa122/.config/hypr/waybar/wireguard-manager"

STATUS_CONNECTED_STR='{"text":"Connected","class":"connected","alt":"connected"}'
STATUS_DISCONNECTED_STR='{"text":"Disconnected","class":"disconnected","alt":"disconnected"}'

function askpass() {
  rofi -dmenu -password -no-fixed-num-lines -p "Sudo password : " -theme $ROFI_CONFIG 
}

function status_wireguard() {
  systemctl is-active $WG_SERVICE_NAME >/dev/null 2>&1
  return $?
}

function toggle_wireguard() {
  status_wireguard && \
     SUDO_ASKPASS=$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh sudo -A systemctl stop $WG_SERVICE_NAME || \
     SUDO_ASKPASS=$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh sudo -A systemctl start $WG_SERVICE_NAME
}

case $1 in
  -s | --status)
    status_wireguard && echo $STATUS_CONNECTED_STR || echo $STATUS_DISCONNECTED_STR
    ;;
  -t | --toggle)
    toggle_wireguard
    ;;
  *)
    askpass
    ;;
esac
