# Wireguard-manager

This is a simple, stupid `waybar` extension for toggling `wireguard`. It uses
`rofi` for password prompting, but you could use anything you like.

## Screenshots

![VPN switched off](screenshots/vpn-off.png)
*VPN switched off, as seen in Waybar.*

![Password prompt](screenshots/password-prompt.png)
*Password prompt with Rofi.*

![VPN switched on](screenshots/vpn-on.png)
*VPN switched on, as seen in Waybar.*

## Pre-requisites

You need to be able to manage Wireguard using Systemd, even though it should
not be too difficult to change the script to use `wg` directly.

If your Wireguard interface is `wg0`, enable the service using :

```bash
sudo systemctl enable wg-quick@wg0.service
sudo systemctl daemon-reload
```

You also need `rofi`.

## Installation

Clone the repository in `~/.config/waybar/wireguard-manager`, then add this to
`~/.config/waybar/config` :

```json
"custom/wireguard-manager": {
    "interval": 3,
    "return-type": "json",
    "format-icons": {
        "connected": "<span color=\"#50fa7b\">VPN: 🔒</span>",
        "disconnected": "<span color=\"#ff5555\">VPN: 🔓</span>"
    },
    "on-click": "exec ~/.config/waybar/wireguard-manager/wireguard-manager.sh -t",
    "exec": "exec ~/.config/waybar/wireguard-manager/wireguard-manager.sh -s",
    "format": "{icon}"
}
```

See [Waybar's wiki](https://github.com/Alexays/Waybar/wiki/Module:-Custom) for
more information on how to customize this.

## Usage

With the given configuration, the status of the connection will be updated every
3 seconds. You can switch on/off the connection to your peer by clicking on the
icon in Waybar.

## Customization

This module is simple enough for anyone to customize it. You can change the way
the rofi prompt looks by editing `rofi.rasi`, or you can use any other way to
prompt the password. You can also change the way things look in Waybar by
editing the sample configuration.

## Contributions

Contributions are most welcome, feel free to submit any idea or improvement you
can think of.

## See also

If you are a NetworkManager user, maybe you should rather use
[wireguard-rofi-waybar ](https://github.com/HarHarLinks/wireguard-rofi-waybar), which seems to offer
way more functionalities!

