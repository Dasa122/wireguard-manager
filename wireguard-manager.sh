#!/usr/bin/env bash

STATUS_CONNECTED_STR='{"text":"Connected","class":"connected","alt":"connected"}'
STATUS_DISCONNECTED_STR='{"text":"Disconnected","class":"disconnected","alt":"disconnected"}'

function askpass() {
  rofi -dmenu -password -no-fixed-num-lines -p "Sudo password : " -theme $ROFI_CONFIG 
}

function status_wireguard() {
  systemctl is-active $SERVICE_NAME >/dev/null 2>&1
  return $?
}

function toggle_wireguard() {
  status_wireguard && \
     SUDO_ASKPASS=$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh sudo -A systemctl stop $SERVICE_NAME || \
     SUDO_ASKPASS=$WG_MANAGER_SCRIPT_DIR/wireguard-manager.sh sudo -A systemctl start $SERVICE_NAME
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
