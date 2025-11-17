{ user, pkgs, ... }:
{
  home-manager.users.${user} = {
    home.packages = [ pkgs.television ];

    xdg.configFile = {
      "television/cable/dotnet-projects.toml" = {
        force = true;
        source = (pkgs.formats.toml { }).generate "dotnet-projects.toml" {
          metadata = {
            name = "dotnet-projects";
            requirements = [ ];
            description = "A channel to select from .NET projects (.csproj) on your local machine.";
          };
          source = {
            command = "glob **/*.csproj -d 5 | where {|file| let doc = try { open $file | from xml } catch { {} }; let sdk = try { $doc.attributes.Sdk? } catch { \"\" }; let outType = try { (($doc.content | where {|e| $e.tag == 'PropertyGroup'} | first).content | where {|e| $e.tag == 'OutputType'}).content | each {|e| $e.content} | first | first } catch { \"\" }; (($sdk | str contains 'Web') or (($sdk | str contains 'Microsoft.NET.Sdk') and ($outType | str contains 'Exe'))) } | each { |f| $\"($f | path parse | get stem)|($f)\" } | str join (char newline)";
            shell = "nu";
            display = "{split:|:0}";
            output = "{split:|:1}";
          };
          preview = {
            command = "bat --color=always {split:|:1}";
          };
          keybindings = {
            ctrl-e = "actions:edit";
          };
          actions = {
            edit = {
              description = "Open the project file in editor";
              command = "hx {split:|:1}";
              mode = "execute";
            };
          };
        };
      };
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
      # Fix: TV template engine parses ${...} as a TV template and fails with
      # "Unclosed shell variable brace". Use $HOME/.config instead of ${XDG_CONFIG_HOME:-...}.
      "television/cable/channels.toml" = {
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

      # Fix: ${EDITOR:-vim} confuses TV template engine. Use hx directly.
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

      # Fix: use explicit shell = "bash" so ls resolves to system ls, not nushell's built-in
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

      # Fix: $HOME doesn't expand in nushell context
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

      # Fix: preview command was broken (jq expression embedded as TV template instead of gh command)
      "television/cable/gh-issues.toml" = {
        force = true;
        text = ''
          [metadata]
          name = "gh-issues"
          description = "List GitHub issues for the current repo"
          requirements = ["gh", "jq"]

          [source]
          command = "gh issue list --state open --limit 100 --json number,title,createdAt,author,labels | jq -r 'sort_by(.createdAt) | reverse | .[] | \"  \\u001b[32m#\\(.number)\\u001b[39m   \\(.title) \\u001b[33m@\\(.author.login)\\u001b[39m\" + (if (.labels | length) > 0 then \" \" + ([.labels[] | \"\\u001b[35m\" + .name + \"\\u001b[39m\"] | join(\" \")) else \"\" end)'"
          shell = "bash"
          ansi = true
          output = "{strip_ansi|split:#:1|split: :0}"

          [preview]
          command = "gh issue view '{strip_ansi|split:#:1|split: :0}'"

          [ui.preview_panel]
          header = "{strip_ansi|split:#:1|split: :0}"
        '';
      };

      # Fix: same broken preview as gh-issues
      "television/cable/gh-prs.toml" = {
        force = true;
        text = ''
          [metadata]
          name = "gh-prs"
          description = "List GitHub PRs for the current repo"
          requirements = ["gh", "jq"]

          [source]
          command = "gh pr list --state open --limit 100 --json number,title,createdAt,author,labels | jq -r 'sort_by(.createdAt) | reverse | .[] | \"  \\u001b[32m#\\(.number)\\u001b[39m   \\(.title) \\u001b[33m@\\(.author.login)\\u001b[39m\" + (if (.labels | length) > 0 then \" \" + ([.labels[] | \"\\u001b[35m\" + .name + \"\\u001b[39m\"] | join(\" \")) else \"\" end)'"
          shell = "bash"
          ansi = true
          output = "{strip_ansi|split:#:1|split: :0}"

          [preview]
          command = "gh pr view '{strip_ansi|split:#:1|split: :0}'"

          [ui.preview_panel]
          header = "{strip_ansi|split:#:1|split: :0}"
        '';
      };

      # Fix: explicit shell = "bash" so {{.Names}} Go templates aren't misinterpreted
      "television/cable/docker-containers.toml" = {
        force = true;
        text = ''
          [metadata]
          name = "docker-containers"
          description = "List and manage Docker containers"
          requirements = ["docker", "jq"]

          [source]
          command = ["docker ps --format '{{.Names}}\\t{{.Image}}\\t{{.Status}}'", "docker ps -a --format '{{.Names}}\\t{{.Image}}\\t{{.Status}}'"]
          shell = "bash"
          display = "{split:\\t:0} ({split:\\t:2})"
          output = "{split:\\t:0}"

          [preview]
          command = "docker inspect '{split:\\t:0}' | jq -C '.[0] | {Name, State, Config: {Image: .Config.Image, Cmd: .Config.Cmd}, NetworkSettings: {IPAddress: .NetworkSettings.IPAddress}}'"

          [ui]
          layout = "portrait"

          [keybindings]
          ctrl-s = "actions:start"
          f2 = "actions:stop"
          ctrl-r = "actions:restart"
          ctrl-l = "actions:logs"
          ctrl-e = "actions:exec"
          ctrl-d = "actions:remove"

          [actions.start]
          description = "Start the selected container"
          command = "docker start '{split:\\t:0}'"
          mode = "fork"

          [actions.stop]
          description = "Stop the selected container"
          command = "docker stop '{split:\\t:0}'"
          mode = "fork"

          [actions.restart]
          description = "Restart the selected container"
          command = "docker restart '{split:\\t:0}'"
          mode = "fork"

          [actions.logs]
          description = "Follow logs of the selected container"
          command = "docker logs -f '{split:\\t:0}'"
          mode = "execute"

          [actions.exec]
          description = "Execute shell in the selected container"
          command = "docker exec -it '{split:\\t:0}' /bin/sh"
          mode = "execute"

          [actions.remove]
          description = "Remove the selected container"
          command = "docker rm '{split:\\t:0}'"
          mode = "execute"
        '';
      };

      # Fix: explicit shell = "bash" for Go template format strings
      "television/cable/docker-compose.toml" = {
        force = true;
        text = ''
          [metadata]
          name = "docker-compose"
          description = "Manage Docker Compose services"
          requirements = ["docker"]

          [source]
          command = "docker compose ps --format '{{.Name}}\\t{{.Service}}\\t{{.Status}}'"
          shell = "bash"
          display = "{split:\\t:1} ({split:\\t:2})"
          output = "{split:\\t:1}"

          [preview]
          command = "docker compose logs --tail=30 --no-log-prefix '{split:\\t:1}'"

          [actions.up]
          description = "Start the selected service"
          command = "docker compose up -d '{split:\\t:1}'"
          mode = "fork"

          [actions.down]
          description = "Stop and remove the selected service"
          command = "docker compose down '{split:\\t:1}'"
          mode = "fork"

          [actions.restart]
          description = "Restart the selected service"
          command = "docker compose restart '{split:\\t:1}'"
          mode = "fork"

          [actions.logs]
          description = "Follow logs of the selected service"
          command = "docker compose logs -f '{split:\\t:1}'"
          mode = "execute"
        '';
      };

      # Fix: source uses bash pipeline with 2>/dev/null, grep, sort
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
          display = "{split:\\::0} ({split:\\::1}% {split:\\::2})"
          output = "{split:\\::0}"

          [preview]
          command = "nmcli -t -f SSID,BSSID,MODE,FREQ,SIGNAL,SECURITY,ACTIVE device wifi list 2>/dev/null | grep '^{split:\\::0}:'"
          shell = "bash"

          [actions.connect]
          description = "Connect to the selected network"
          command = "nmcli device wifi connect '{split:\\::0}'"
          mode = "execute"
        '';
      };

      # Fix: source uses complex bash pipeline (awk, sed, 2>/dev/null)
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

      # Fix: preview and action use && chaining; $SHELL replaced with nu
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

      # Fix: source/preview use 2>/dev/null and ||
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

      # Fix: replaced Go template {{...}} source with custom-columns (simpler, no template issues)
      "television/cable/k8s-pods.toml" = {
        force = true;
        text = ''
          [metadata]
          name = "k8s-pods"
          description = "List and preview Pods in a Kubernetes Cluster"
          requirements = ["kubectl"]

          [source]
          command = [
            "kubectl get pods --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
            "kubectl get pods --all-namespaces --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
          ]
          shell = "bash"
          output = "{1}"

          [preview]
          command = "kubectl describe -n {0} pods/{1}"

          [ui.preview_panel]
          size = 60

          [keybindings]
          ctrl-d = "actions:delete"
          ctrl-e = "actions:exec"
          ctrl-l = "actions:logs"

          [actions.exec]
          description = "Execute shell inside the selected Pod"
          command = "kubectl exec -i -t -n {0} pods/{1} -- /bin/sh"
          mode = "execute"

          [actions.delete]
          description = "Delete the selected Pod"
          command = "kubectl delete -n {0} pods/{1}"
          mode = "execute"

          [actions.logs]
          description = "Follow logs of the selected Pod"
          command = "kubectl logs -f -n {0} pods/{1}"
          mode = "execute"
        '';
      };

      "television/cable/k8s-services.toml" = {
        force = true;
        text = ''
          [metadata]
          name = "k8s-services"
          description = "List and preview Services in a Kubernetes Cluster"
          requirements = ["kubectl"]

          [source]
          command = [
            "kubectl get services --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
            "kubectl get services --all-namespaces --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
          ]
          shell = "bash"
          output = "{1}"

          [preview]
          command = "kubectl describe -n {0} services/{1}"

          [ui.preview_panel]
          size = 60

          [keybindings]
          ctrl-d = "actions:delete"

          [actions.delete]
          description = "Delete the selected Service"
          command = "kubectl delete -n {0} services/{1}"
          mode = "execute"
        '';
      };

      "television/cable/k8s-deployments.toml" = {
        force = true;
        text = ''
          [metadata]
          name = "k8s-deployments"
          description = "List and preview Deployments in a Kubernetes Cluster"
          requirements = ["kubectl"]

          [source]
          command = [
            "kubectl get deployments --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
            "kubectl get deployments --all-namespaces --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
          ]
          shell = "bash"
          output = "{1}"

          [preview]
          command = "kubectl describe -n {0} deployments/{1}"

          [ui.preview_panel]
          size = 60

          [keybindings]
          ctrl-d = "actions:delete"

          [actions.delete]
          description = "Delete the selected Deployment"
          command = "kubectl delete -n {0} deployments/{1}"
          mode = "execute"
        '';
      };

      # Fix: add explicit shell = "bash" for consistency
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

      "television/config.toml" = {
        force = true;
        text = ''
          # General settings
          tick_rate = 50
          default_channel = "files"
          # History settings
          history_size = 200
          global_history = false

          [ui]
          ui_scale = 100
          orientation = "landscape"
          theme = "catppuccin"

          [ui.input_bar]
          position = "top"
          prompt = ">"
          border_type = "rounded"

          [ui.status_bar]
          separator_open = ""
          separator_close = ""
          hidden = false

          [ui.results_panel]
          border_type = "rounded"

          [ui.preview_panel]
          size = 50
          scrollbar = true
          border_type = "rounded"
          hidden = false

          [ui.help_panel]
          show_categories = true
          hidden = true

          [ui.remote_control]
          show_channel_descriptions = true
          sort_alphabetically = true

          # Keybindings
          [keybindings]
          # Application control
          esc = "quit"
          ctrl-c = "quit"

          # Navigation and selection
          down = "select_next_entry"
          ctrl-n = "select_next_entry"
          ctrl-j = "select_next_entry"
          up = "select_prev_entry"
          ctrl-p = "select_prev_entry"
          ctrl-k = "select_prev_entry"

          # History navigation
          ctrl-up = "select_prev_history"
          ctrl-down = "select_next_history"

          # Multi-selection
          tab = "toggle_selection_down"
          backtab = "toggle_selection_up"
          enter = "confirm_selection"

          # Preview panel control
          pagedown = "scroll_preview_half_page_down"
          pageup = "scroll_preview_half_page_up"

          # Data operations
          ctrl-y = "copy_entry_to_clipboard"
          ctrl-r = "reload_source"
          ctrl-s = "cycle_sources"

          # UI Features
          ctrl-t = "toggle_remote_control"
          ctrl-o = "toggle_preview"
          ctrl-h = "toggle_help"
          f12 = "toggle_status_bar"
          ctrl-l = "toggle_layout"

          # Input field actions
          backspace = "delete_prev_char"
          ctrl-w = "delete_prev_word"
          ctrl-u = "delete_line"
          delete = "delete_next_char"
          left = "go_to_prev_char"
          right = "go_to_next_char"
          home = "go_to_input_start"
          ctrl-a = "go_to_input_start"
          end = "go_to_input_end"
          ctrl-e = "go_to_input_end"

          # Event bindings
          [events]
          mouse-scroll-up = "scroll_preview_up"
          mouse-scroll-down = "scroll_preview_down"

          # Shell integration
          [shell_integration]
          fallback_channel = "files"

          [shell_integration.channel_triggers]
          "alias" = ["alias", "unalias"]
          "env" = ["export", "unset"]
          "dotenv" = ["dotenv"]
          "dirs" = ["cd", "ls", "rmdir"]
          "files" = [
            "cat",
            "less",
            "head",
            "tail",
            "vim",
            "nano",
            "bat",
            "cp",
            "mv",
            "rm",
            "touch",
            "chmod",
            "chown",
            "ln",
            "tar",
            "zip",
            "unzip",
            "gzip",
            "gunzip",
            "xz",
          ]
          "git-diff" = ["git add", "git restore"]
          "git-branch" = [
            "git co",
            "git br",
            "git brD",
            "git ps",
            "git pl",
            "git rb",
            "git cp",
            "git checkout",
            "git branch",
            "git merge",
            "git rebase",
            "git pull",
            "git push",
            "git rbi",
          ]
          "git-log" = ["git log", "git show"]
          "docker-images" = ["docker run"]
          "git-repos" = ["nvim", "code", "hx", "git clone", "vim", "cr", "vir"]

          [shell_integration.keybindings]
          "smart_autocomplete" = "ctrl-t"
          "command_history" = "ctrl-r"
        '';
      };

      "television/themes/catppuccin.toml" = {
        force = true;
        text = ''
          # general
          border_fg = '#6c7086'
          text_fg = '#cdd6f4'
          dimmed_text_fg = '#6c7086'
          # input
          input_text_fg = '#f38ba8'
          result_count_fg = '#f38ba8'
          # results
          result_name_fg = '#89b4fa'
          result_line_number_fg = '#f9e2af'
          result_value_fg = '#b4befe'
          selection_fg = '#a6e3a1'
          selection_bg = '#313244'
          match_fg = '#f38ba8'
          # preview
          preview_title_fg = '#fab387'
          # modes
          channel_mode_fg = '#1e1e2e'
          channel_mode_bg = '#f5c2e7'
          remote_control_mode_fg = '#1e1e2e'
          remote_control_mode_bg = '#a6e3a1'
        '';
      };
    };
  };
}
