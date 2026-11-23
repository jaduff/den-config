# modules/desktop/dux/terminal.nix
{ den, ... }:
{
  den.aspects.desktop.kitty = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.kitty ];
      environment.sessionVariables.TERMINAL = "kitty";
    };

    hjem = _: {
      files.".config/kitty/kitty.conf" = {
        text = ''
          font_family      JetBrainsMono Nerd Font
          font_size        11
          cursor_shape     beam
          enable_audio_bell no
          window_padding_width 8
          hide_window_decorations yes    # let niri own the frame
          confirm_os_window_close 0
          map ctrl+shift+enter new_window_with_cwd
          map ctrl+shift+t     new_tab_with_cwd

          # DMS writes theme colours here; keep last so it wins.
          include themes/dms.conf
        '';
        clobber = true;
      };
    };
  };
}

