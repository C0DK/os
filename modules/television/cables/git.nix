{
  user,
  pkgs,
  ...
}:
{
  home-manager.users.${user}.xdg.configFile = {
    "television/cable/git-repos.toml" = {
      force = true;
      source = (pkgs.formats.toml { }).generate "git-repos.toml" {
        metadata = {
          name = "git-repos";
          requirements = [
            "fd"
            "git"
          ];
          description = "A channel to select from git repositories on your local machine.";
        };
        source = {
          command = "fd -g .git -HL -t d -d 10 --prune ($env.HOME + '/Documents') | lines | each { |it| $it | path dirname } | str join (char newline)";
          shell = "nu";
          display = "{split:/:-1}";
        };
        preview = {
          command = "git -C '{}' log -n 200 --pretty=medium --all --graph --color";
        };
        keybindings = {
          ctrl-o = "actions:cd";
          ctrl-e = "actions:edit";
        };
        actions = {
          cd = {
            description = "Open a new shell in the selected repository";
            command = "cd {}";
            mode = "execute";
          };
          edit = {
            description = "Open the repository in editor";
            command = "hx {}";
            mode = "execute";
          };
        };
      };
    };

    "television/cable/git-tags.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "git-tags"
        description = "Browse and checkout git tags"
        requirements = ["git"]

        [source]
        command = "git tag --sort=-creatordate"
        shell = "bash"
        no_sort = true
        frecency = false

        [preview]
        command = "git show --color=always '{}'"

        [keybindings]
        enter = "actions:checkout"
        ctrl-d = "actions:delete"

        [actions.checkout]
        description = "Checkout the selected tag"
        command = "git checkout '{}'"
        mode = "execute"

        [actions.delete]
        description = "Delete the selected tag"
        command = "git tag -d '{}'"
        mode = "execute"
      '';
    };

    "television/cable/git-worktrees.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "git-worktrees"
        description = "List and switch between git worktrees"
        requirements = ["git"]

        [source]
        command = "git worktree list --porcelain | grep '^worktree' | cut -d' ' -f2-"
        shell = "bash"

        [preview]
        command = "cd '{}' && git log --oneline -10 --color=always && echo && git status --short"
        shell = "bash"

        [keybindings]
        enter = "actions:cd"
        ctrl-d = "actions:remove"

        [actions.cd]
        description = "Open a nushell session in the selected worktree"
        command = "cd '{}' && nu"
        shell = "bash"
        mode = "execute"

        [actions.remove]
        description = "Remove the selected worktree"
        command = "git worktree remove '{}'"
        mode = "execute"
      '';
    };
  };
}
