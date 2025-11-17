{ user, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ tmux ];
  home-manager.users.${user}.programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    extraConfig = ''
      # Forward app-set window title (from nushell hook) to ghostty
      set -g set-titles on
      set -g set-titles-string "#{?#T,[#S] #T,[#S] #{pane_current_path}}"

      set -as terminal-features ",xterm-ghostty:hyperlinks"
      set -g allow-passthrough on
      # True color support
      set -ag terminal-overrides ",xterm-ghostty:RGB"
      set-environment -g COLORTERM truecolor


      # session stuff
      bind -n M-s choose-session 
      bind -n M-N new-session
      bind -n M-n new-session -c "#{pane_current_path}"
      bind -n M-r command-prompt -I "#S" "rename-session '%%'"
      bind -n M-R rename-session "#{pane_current_command}"
      bind -n M-b switch-client -l
      bind -n M-Right switch-client -n
      bind -n M-l switch-client -n
      bind -n M-Left switch-client -p
      bind -n M-h switch-client -p
      bind -n M-d kill-session

      # Split panes with intuitive keys
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Vi copy mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Slower mouse scroll (default 5 lines is too aggressive)
      bind -T copy-mode-vi WheelUpPane   send-keys -X -N 1 scroll-up
      bind -T copy-mode-vi WheelDownPane send-keys -X -N 1 scroll-down
      bind -T copy-mode    WheelUpPane   send-keys -X -N 1 scroll-up
      bind -T copy-mode    WheelDownPane send-keys -X -N 1 scroll-down

      bind-key -T copy-mode Escape send-keys -X cancel
      bind-key -T copy-mode-vi Escape send-keys -X cancel

      # Reload config
      bind R source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

      # Catppuccin Frappe status bar
      set -g status-style "bg=#303446,fg=#c6d0f5"
      set -g status-left-length 40
      set -g status-left "#[bg=#8caaee,fg=#303446,bold] #S #[bg=#303446,fg=#8caaee]"
      set -g status-right ""
      set -g window-status-format "#[fg=#626880] #I:#W "
      set -g window-status-current-format "#[fg=#e5c890,bold] #I:#W "
      set -g window-status-separator ""

      # Pane borders
      set -g pane-border-style "fg=#414559"
      set -g pane-active-border-style "fg=#8caaee"

      # Message style
      set -g message-style "bg=#e5c890,fg=#303446"

      # Status position
      set -g status-position bottom
    '';
  };
}
