{ user, ... }:
{
  home-manager.users.${user}.xdg.configFile = {
    "television/cable/files.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "files"
        description = "A channel to select files and directories"
        requirements = ["fd", "bat"]

        [source]
        command = ["fd -t f", "fd -t f -H"]

        [preview]
        command = "bat -n --color=always '{}'"
        env = { BAT_THEME = "ansi" }

        [keybindings]
        shortcut = "f1"
        f12 = "actions:edit"
        ctrl-up = "actions:goto_parent_dir"

        [actions.edit]
        description = "Opens the selected entries with the default editor"
        command = "hx '{}'"
        mode = "execute"

        [actions.goto_parent_dir]
        description = "Re-opens tv in the parent directory"
        command = "tv files .."
        mode = "execute"
      '';
    };

    "television/cable/dirs.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "dirs"
        description = "A channel to select from directories"
        requirements = ["fd"]

        [source]
        command = ["fd -t d", "fd -t d --hidden"]

        [preview]
        command = "ls -la --color=always '{}'"
        shell = "bash"

        [keybindings]
        shortcut = "f2"
      '';
    };

    "television/cable/dotfiles.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "dotfiles"
        description = "A channel to select from your user's dotfiles"
        requirements = ["fd", "bat"]

        [source]
        command = "fd -t f . $HOME/.config"
        shell = "bash"

        [preview]
        command = "bat -n --color=always '{}'"
      '';
    };

    "television/cable/downloads.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "downloads"
        description = "Browse recent files in Downloads folder"
        requirements = ["fd", "bat"]

        [source]
        command = "fd -t f . ~/Downloads 2>/dev/null | head -200"
        shell = "bash"

        [preview]
        command = "bat -n --color=always '{}' 2>/dev/null || file '{}'"
        shell = "bash"
        env = { BAT_THEME = "ansi" }

        [keybindings]
        enter = "actions:open"
        ctrl-d = "actions:delete"
        ctrl-m = "actions:move"

        [actions.open]
        description = "Open the selected file with default application"
        command = "xdg-open '{}'"
        mode = "fork"

        [actions.delete]
        description = "Delete the selected file"
        command = "rm -i '{}'"
        mode = "execute"

        [actions.move]
        description = "Move the selected file to current directory"
        command = "mv '{}' ."
        mode = "fork"
      '';
    };
  };
}
