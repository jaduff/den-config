{ den, inputs, ... }:
let
  # DMS (`dms setup`) writes its runtime fragments here. Our generated config
  # lives in the nix store, so these MUST NOT be bare relative paths: relative
  # includes resolve against the *including file's* directory, i.e.
  # /nix/store/…-niri-config-checked/.
  #
  # `~` expansion in include paths requires niri >= 26.04. Check: niri --version
  # On older niri, drop the tilde and hardcode the real home path instead:
  #   fragDir = "/home/<user>/.config/niri/dms";
  fragDir = "~/.config/niri/dms";

  # Flip to "" to make missing fragments a hard error while debugging.
  # Remember to put "optional=true" back, or every build fails until
  # `dms setup` has been run once on the target machine.
  optionalFrag = "optional=true";

  niriKdl = ''
    // Managed declaratively. Runtime fragments live in ~/.config/niri/dms/.

    include ${optionalFrag} "${fragDir}/colors.kdl"
    include ${optionalFrag} "${fragDir}/layout.kdl"
    include ${optionalFrag} "${fragDir}/alttab.kdl"
    include ${optionalFrag} "${fragDir}/windowrules.kdl"
    // Deliberately NOT included: dms/binds.kdl, dms/binds-next.kdl
    // Keybinds below are the single source of truth; DMS would duplicate them.

    input {
        keyboard { xkb { layout "us"; }
        }
        touchpad { tap; natural-scroll; }
        focus-follows-mouse max-scroll-amount="30%"
    }

    layout {
        gaps 5
        center-focused-column "never"
        background-color "transparent"
        default-column-width { proportion 0.5; }
        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }
        focus-ring { width 4; active-color "#7fc8ff"; }
        border { off; }
    }

    prefer-no-csd
    hotkey-overlay { skip-at-startup; }

    layer-rule {
        match namespace="^quickshell$"
        place-within-backdrop true
    }

    window-rule {
        match is-active=false
        opacity 0.9
    }

    window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
    }

    window-rule {
        match app-id=r#"^dev\.duxlabs\.shell$"#
        open-floating true
    }

    window-rule {
        match app-id=r#"^(org\.gnome\.)"#
        draw-border-with-background false
    }

    window-rule {
        match app-id=r#"^(com\.mitchellh\.ghostty|Alacritty|kitty|zen)$"#
        draw-border-with-background false
    }

    binds {
        Mod+Shift+Page_Up { set-window-height "700"; }
        Mod+Return { spawn "kitty"; }
        Mod+T hotkey-overlay-title="Terminal" { spawn "kitty"; }
        Mod+Q { close-window; }
        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down  { focus-window-down; }
        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Ctrl+Up   { move-window-up; }
        Mod+Ctrl+Down { move-window-down; }
        Mod+Comma { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }
        Mod+R { switch-preset-column-width; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Print { screenshot; }
        Mod+Escape { toggle-keyboard-shortcuts-inhibit; }
        Mod+Shift+E { quit; }
        Mod+Shift+P { power-off-monitors; }

        Mod+Space hotkey-overlay-title="Application Launcher" {
            spawn "dms" "ipc" "call" "spotlight" "toggle";
        }
        Mod+V hotkey-overlay-title="Clipboard" {
            spawn "dms" "ipc" "call" "clipboard" "toggle";
        }
        Mod+M hotkey-overlay-title="Media" {
            spawn "dms" "ipc" "call" "dash" "toggle" "media";
        }
        Mod+Alt+Comma hotkey-overlay-title="Settings" {
            spawn "dms" "ipc" "call" "settings" "focusOrToggle";
        }
        Mod+Ctrl+N hotkey-overlay-title="Notifications" {
            spawn "dms" "ipc" "call" "notifications" "toggle";
        }
        Mod+Y hotkey-overlay-title="Wallpapers" {
            spawn "dms" "ipc" "call" "dash" "toggle" "wallpaper";
        }
        Ctrl+Alt+Delete hotkey-overlay-title="Task Manager" {
            spawn "dms" "ipc" "call" "processlist" "focusOrToggle";
        }
        Mod+Alt+L hotkey-overlay-title="Lock Screen" {
            spawn "dms" "ipc" "call" "lock" "lock";
        }

        XF86AudioRaiseVolume allow-when-locked=true repeat=false {
            spawn "dms" "ipc" "call" "audio" "increment" "3";
        }
        XF86AudioLowerVolume allow-when-locked=true repeat=false {
            spawn "dms" "ipc" "call" "audio" "decrement" "3";
        }
        XF86AudioMute allow-when-locked=true repeat=false {
            spawn "dms" "ipc" "call" "audio" "mute";
        }
        XF86AudioPlay allow-when-locked=true repeat=false {
            spawn "dms" "ipc" "call" "mpris" "playPause";
        }
        XF86AudioNext allow-when-locked=true repeat=false {
            spawn "dms" "ipc" "call" "mpris" "next";
        }
        XF86AudioPrev allow-when-locked=true repeat=false {
            spawn "dms" "ipc" "call" "mpris" "previous";
        }
        XF86MonBrightnessUp allow-when-locked=true repeat=false {
            spawn "dms" "ipc" "call" "brightness" "increment" "5" "";
        }
        XF86MonBrightnessDown allow-when-locked=true repeat=false {
            spawn "dms" "ipc" "call" "brightness" "decrement" "5" "";
        }
        XF86TouchpadToggle allow-when-locked=true repeat=false {
            spawn "niri" "msg" "action" "toggle-touchpad";
        }
    }
  '';

  checkedConfig = pkgs:
    let src = pkgs.writeText "niri-config.kdl" niriKdl;
    in pkgs.runCommand "niri-config-checked" { nativeBuildInputs = [ pkgs.niri ]; } ''
      niri validate --config ${src}
      install -Dm444 ${src} $out
    '';
in
{
  den.aspects.desktop.niri = {
    nixos = { pkgs, ... }:
      let
        unstable = import inputs.unstable {
          inherit (pkgs.stdenv.hostPlatform) system;
        };
      in
      {
        # pkgs.niri (runtime AND checkedConfig's validator) now comes from unstable.
        nixpkgs.overlays = [ (final: prev: { niri = unstable.niri; }) ];

        programs.niri.enable = true;

        environment.etc."xdg/niri/config.kdl".enable = false;
      };

  };
    den.aspects.desktop.niri.hjem = { pkgs, ... }: {
      files.".config/niri/config.kdl" = {
        source = checkedConfig pkgs;
        clobber = true;
      };
    };
}
