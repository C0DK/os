{ user, ... }:
{
  home-manager.users.${user}.xdg.configFile."television/cable/channels.toml" = {
    force = true;
    text = ''
      [metadata]
      name = "channels"
      description = "Select a television channel"
      requirements = ["tv", "bat"]

      [source]
      command = ["tv list-channels"]

      [preview]
      command = "bat -pn --color=always $HOME/.config/television/cable/{}.toml 2>/dev/null || echo 'Built-in channel (no cable file)'"
      shell = "bash"

      [keybindings]
      enter = "actions:channel-enter"

      [actions.channel-enter]
      description = "Enter a television channel"
      command = "tv {}"
      mode = "execute"
    '';
  };
}
