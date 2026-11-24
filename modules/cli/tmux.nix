# modules/apps/tmux.nix
{ den, ... }:
{
  den.aspects.cli.tmux.nixos = { pkgs, ... }: {
    programs.tmux = {
      enable = true;

      # --- typed options: these are what the module actually models ---
      clock24 = true;          # default false
      aggressiveResize = true; # default false
      baseIndex = 1;           # default 0, so first window is 1
      keyMode = "vi";          # default "emacs"; sets both status-keys and mode-keys
      escapeTime = 10;         # default 500ms; 10 makes ESC feel instant in vim
      terminal = "tmux-256color"; # default "screen"

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        resurrect
        continuum
        vim-tmux-navigator
      ];

      # runs BEFORE the plugins are sourced
      extraConfigBeforePlugins = ''
        set -g focus-events on
      '';

      # runs AFTER the plugins are sourced
      extraConfig = ''
        set -g mouse on
        set -g set-clipboard on
        set -g history-limit 50000
        set -as terminal-features ",*:RGB"

        # splits inherit the current directory
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # reload the generated config
        bind r source-file /etc/tmux.conf \\; display "reloaded"

        # plugin settings (plain `set -g @...` lines)
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'
        set -g @resurrect-capture-pane-contents 'on'
      '';
    };
  };
}

