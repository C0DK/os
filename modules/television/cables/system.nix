{ user, ... }:
{
  home-manager.users.${user}.xdg.configFile = {
    "television/cable/wifi.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "wifi"
        description = "Scan and connect to WiFi networks"
        requirements = ["nmcli"]

        [source]
        command = "nmcli -t -f SSID,SIGNAL,SECURITY device wifi list 2>/dev/null | grep -v '^:' | sort -t: -k2 -rn"
        shell = "bash"
        display = "{split:\::0} ({split:\::1}% {split:\::2})"
        output = "{split:\::0}"

        [preview]
        command = "nmcli -t -f SSID,BSSID,MODE,FREQ,SIGNAL,SECURITY,ACTIVE device wifi list 2>/dev/null | grep '^{split:\::0}:'"
        shell = "bash"

        [actions.connect]
        description = "Connect to the selected network"
        command = "nmcli device wifi connect '{split:\::0}'"
        mode = "execute"
      '';
    };

    "television/cable/ports.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "ports"
        description = "List listening ports and associated processes"
        requirements = ["ss", "awk"]

        [source]
        command = "ss -tlnp 2>/dev/null | tail -n +2 | awk '{gsub(/.*:/,\"\",$4); print $4, $1, $6}' | sed 's/users:((\"//; s/\".*//'"
        shell = "bash"
        display = "{split: :0} ({split: :2})"

        [preview]
        command = "ss -tlnp 2>/dev/null | grep ':{split: :0} ' | head -20"
        shell = "bash"

        [ui.preview_panel]
        size = 40

        [actions.kill]
        description = "Kill the process listening on the selected port"
        command = "fuser -k {split: :0}/tcp"
        mode = "execute"
      '';
    };
  };
}
