# modules/desktop/hyprland.nix
{
  den,
  lib,
  ...
}:
{
  den.aspects.desktop.hyprland = {
    # The nested `bar` aspect below is pulled in here.
    includes = [ den.aspects.desktop.hyprland.bar ];

    # ── System side ────────────────────────────────────────────────────
    nixos = { pkgs, ... }: {
      programs.hyprland = {
        enable = true;
        withUWSM = true;        # recommended launch path, systemd-integrated
        xwayland.enable = true; # keep X11 apps (Steam, some Electron apps) working
      };

      # Electron/Chromium: use Wayland natively.
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      environment.systemPackages = with pkgs; [
        kitty              # terminal referenced in keybinds
        wofi               # launcher referenced in keybinds
        mako               # notification daemon
        hyprlock           # lockscreen
        hypridle           # idle daemon (config: services.hypridle in HM)
        hyprpaper          # wallpaper daemon
        hyprpolkitagent    # auth agent
        grim slurp         # screenshots
        wl-clipboard       # wl-copy / wl-paste
        brightnessctl playerctl
        networkmanagerapplet
      ];

      # Icons for Waybar.
      fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

      # hyprlock needs a PAM service to unlock.
      security.pam.services.hyprlock = { };
    };

    # ── User side ──────────────────────────────────────────────────────
    homeManager =
      { pkgs, ... }:
      {
        wayland.windowManager.hyprland = {
          enable = true;

          # UWSM owns the session; HM's systemd integration conflicts with it.
          systemd.enable = false;

          # Home Manager 26.05 defaults to Lua config output; pin hyprlang
          # so the classic, widely-documented `settings` syntax keeps working.
          configType = "hyprlang";

          settings = {
            "$mod" = "SUPER";
            "$terminal" = "kitty";
            "$menu" = "wofi --show drun";

            monitor = [ ",preferred,auto,1" ];

            general = {
              gaps_in = 5;
              gaps_out = 10;
              border_size = 2;
              "col.active_border" = "rgba(89b4faee) rgba(a6e3a1ee) 45deg";
              "col.inactive_border" = "rgba(45475aaa)";
              layout = "dwindle";
            };

            decoration = {
              rounding = 8;
              "col.shadow" = "rgba(00000055)";
              blur = {
                enabled = true;
                size = 4;
                passes = 2;
              };
            };

            animations.enabled = true;
            dwindle.preserve_split = true;

            input = {
              kb_layout = "us";
              follow_mouse = 1;
              touchpad.natural_scroll = true;
            };

            misc = {
              force_default_wallpaper = 0;
              disable_hyprland_logo = true;
            };

            # Waybar is a systemd unit (see the `bar` aspect), not exec-once.
            exec-once = [
              "mako"
              "hyprpaper"
              "hypridle"
            ];

            bind = [
              "$mod, RETURN, exec, $terminal"
              "$mod, D, exec, $menu"
              "$mod, Q, killactive"
              "$mod, M, exit"
              "$mod, E, exec, wofi --show drun"
              "$mod, L, exec, hyprlock"
              "$mod, V, togglefloating"
              "$mod, P, pseudo"
              "$mod, J, togglesplit"
              "$mod, F, fullscreen"
              # focus
              "$mod, left, movefocus, l"
              "$mod, right, movefocus, r"
              "$mod, up, movefocus, u"
              "$mod, down, movefocus, d"
              # workspaces
              "$mod, 1, workspace, 1"
              "$mod, 2, workspace, 2"
              "$mod, 3, workspace, 3"
              "$mod, 4, workspace, 4"
              "$mod, 5, workspace, 5"
              "$mod SHIFT, 1, movetoworkspace, 1"
              "$mod SHIFT, 2, movetoworkspace, 2"
              "$mod SHIFT, 3, movetoworkspace, 3"
              "$mod SHIFT, 4, movetoworkspace, 4"
              "$mod SHIFT, 5, movetoworkspace, 5"
              # media / hardware keys
              ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
              ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
              ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
              # screenshots
              ", PRINT, exec, grim -g \"$(slurp)\" - | wl-copy"
            ];

            bindm = [
              "$mod, mouse:272, movewindow"
              "$mod, mouse:273, resizewindow"
            ];
          };
        };

        home.packages = with pkgs; [ grim slurp wl-clipboard playerctl ];

        home.pointerCursor = {
          gtk.enable = true;
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 24;
        };

        gtk = {
          enable = true;
          iconTheme = {
            package = pkgs.adwaita-icon-theme;
            name = "Adwaita";
          };
        };
      };

    # ── The toolbar (nested aspect, removable) ─────────────────────────
    bar.homeManager = { pkgs, ... }: {
      programs.waybar = {
        enable = true;
        systemd.enable = true; # waybar.service, started via graphical-session.target
        settings = [
          {
            layer = "top";
            position = "top";
            height = 34;
            spacing = 4;
            margin = "6 8 0 8";

            modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
            modules-center = [ "hyprland/window" ];
            modules-right = [
              "tray"
              "pulseaudio"
              "network"
              "cpu"
              "memory"
              "battery"
              "clock"
            ];

            "hyprland/workspaces" = {
              format = "{icon}";
              on-click = "activate";
              all-outputs = true;
              "format-icons" = {
                default = "";
                active = "";
                urgent = "";
              };
            };

            "hyprland/window" = {
              max-length = 60;
              separate-outputs = true;
            };

            tray.spacing = 8;

            "pulseaudio" = {
              format = "{icon} {volume}%";
              format-muted = " muted";
              "format-icons" = { default = [ "" "" "" ]; };
              on-click = "pavucontrol";
            };

            network = {
              "format-wifi" = " {essid}";
              "format-ethernet" = "󰈀 wired";
              "format-disconnected" = "󰤭 offline";
            };

            cpu = { format = " {usage}%"; interval = 5; };
            memory = { format = " {percentage}%"; interval = 10; };

            battery = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              "format-icons" = [ "" "" "" "" "" ];
            };

            clock = {
              format = "{:%a %d %b  %H:%M}";
              tooltip-format = "<tt>{calendar}</tt>";
            };
          }
        ];

        style = ''
          * {
            font-family: "JetBrainsMono Nerd Font", sans-serif;
            font-size: 13px;
            border: none;
            border-radius: 0;
          }

          window#waybar {
            background: rgba(24, 24, 31, 0.86);
            color: #cdd6f4;
            border-radius: 10px;
          }

          #workspaces button {
            padding: 0 8px;
            color: #6c7086;
            background: transparent;
          }

          #workspaces button.active { color: #89b4fa; }
          #workspaces button.urgent { color: #f38ba8; }

          #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray,
          #window, #submap {
            padding: 0 10px;
            margin: 4px 0;
          }

          #battery.warning { color: #f9e2af; }
          #battery.critical { color: #f38ba8; }
        '';
      };

      # Optional: declarative wallpaper. Delete if you don't want one.
      services.hyprpaper = {
        enable = true;
        settings = {
          preload = [ "${pkgs.nixos-artwork.wallpapers.simple-dark-gray}/share/backgrounds/nixos/nixos-wallpaper.png" ];
          wallpaper = [ ",${pkgs.nixos-artwork.wallpapers.simple-dark-gray}/share/backgrounds/nixos/nixos-wallpaper.png" ];
        };
      };
    };
  };
}

