{ den, inputs, ... }:
let
  # One definition of "which niri": used by both the compositor and the
  # config validator, so the validator can never be an older niri than the
  # one you actually run.
  niriPkgOf = pkgs:
    inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.niri;

  # ---------------------------------------------------------------------------
  # HDMI-A-2 is off by default but must remain enableable at runtime.
  #
  # Do NOT use `output "HDMI-A-2" { off; }` here: `off` is the output's
  # *configuration*, and niri re-applies output configuration on every config
  # apply, on hotplug and on monitor power changes. That stomps any
  # `niri msg output HDMI-A-2 on`, so the output could never be turned on.
  #
  # Instead, turn it off exactly once at startup, after the IPC socket exists.
  # Nothing in the config then claims ownership of the output, so runtime
  # changes (CLI or DMS UI) stick until logout.
  # ---------------------------------------------------------------------------
  startupKdl = ''
    spawn-at-startup "sh" "-c" "while [ ! -S '$NIRI_SOCKET' ]; do sleep 0.1; done; sleep 0.5; niri msg output HDMI-A-2 off"
  '';

  # DMS writes its runtime fragments here. Our config lives in the nix store,
  # so these paths must not be bare relative ones.
  fragDir = "~/.config/niri/dms";

  # "" makes a missing fragment a hard error while debugging.
  optionalFrag = "optional=true";

  niriKdl = ''
    // Managed declaratively. Runtime fragments live in ~/.config/niri/dms/.

    include ${optionalFrag} "${fragDir}/colors.kdl"
    include ${optionalFrag} "${fragDir}/alttab.kdl"
    // Not included, because each duplicates something below (includes come
    // first, so conflicts resolve against you):
    //   dms/binds.kdl, dms/binds-next.kdl, dms/layout.kdl, dms/windowrules.kdl

    ${startupKdl}

    // NOTE: keep this block multi-line. Nesting `{ ... }` inside `{ ... }` on
    // one line makes the inner close brace hit the outer one, and KDL needs a
    // node terminator (`;` or newline) after a children block.
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        touchpad {
            tap
            natural-scroll
        }
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
            proportion 1.0
        }
        preset-window-heights {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
            proportion 1.0
        }
        focus-ring {
            width 4
            active-color "#7fc8ff"
        }
        border {
            off
        }
    }

    prefer-no-csd
    hotkey-overlay {
        skip-at-startup
    }

    layer-rule {
        match namespace="^quickshell$"
        place-within-backdrop true
    }

    // Dim unfocused windows. There is no `is-fullscreen` matcher, so exclude
    // the usual fullscreen suspects here and use Mod+Alt+O to toggle the rule
    // off for a specific window when something still gets dimmed.
    window-rule {
        match is-active=false
        exclude app-id=r#"^(mpv|gamescope|org\.videolan\.vlc)$"#
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
        // --- windows -------------------------------------------------------
        Mod+Return { spawn "kitty"; }
        Mod+T hotkey-overlay-title="Terminal" { spawn "kitty"; }
        Mod+Q { close-window; }
        Mod+Shift+Slash hotkey-overlay-title="Important Hotkeys" { show-hotkey-overlay; }

        // --- floating ------------------------------------------------------
        Mod+Shift+Space { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        // --- focus ---------------------------------------------------------
        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down { focus-window-down; }
        Mod+Home { focus-column-first; }
        Mod+End { focus-column-last; }

        // --- moving --------------------------------------------------------
        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Ctrl+Up { move-window-up; }
        Mod+Ctrl+Down { move-window-down; }
        Mod+Comma { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        // --- monitor navigation --------------------------------------------
        Mod+Ctrl+Left { focus-monitor-left; }
        Mod+Ctrl+Right { focus-monitor-right; }
        Mod+Ctrl+Shift+Left { move-column-to-monitor-left; }
        Mod+Ctrl+Shift+Right { move-column-to-monitor-right; }

        // --- sizing --------------------------------------------------------
        Mod+R { switch-preset-column-width; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }
        Mod+F { maximize-column; }
        Mod+Alt+Equal { expand-column-to-available-width; }
        Mod+Alt+C { center-column; }
        Mod+Shift+F { fullscreen-window; }

        // --- opacity escape hatch ------------------------------------------
        Mod+Alt+O { toggle-window-rule-opacity; }

        // --- workspaces ----------------------------------------------------
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
        Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp { move-column-to-workspace-up; }

        // --- system --------------------------------------------------------
        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }
        Mod+Escape { toggle-keyboard-shortcuts-inhibit; }
        Mod+Shift+E { quit; }
        Mod+Shift+P { power-off-monitors; }

        // --- output toggle -------------------------------------------------
        // Flips HDMI-A-2 between on and off using the runtime output state,
        // not the config. Safe with the startup-only approach above.
        Mod+Shift+P hotkey-overlay-title="Toggle HDMI-A-2" {
            spawn-sh "niri msg outputs | grep -q 'HDMI-A-2.*Disabled' && niri msg output HDMI-A-2 on || niri msg output HDMI-A-2 off";
        }

        // --- DMS -----------------------------------------------------------
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

        // --- hardware keys -------------------------------------------------
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
    }

    // spawn-at-startup "xwayland-satellite"
    // screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
  '';

  checkedConfig = pkgs:
    let
      src = pkgs.writeText "niri-config.kdl" niriKdl;
    in
    pkgs.runCommand "niri-config-checked"
      { nativeBuildInputs = [ (niriPkgOf pkgs) ]; }
      ''
        niri validate --config ${src}
        install -Dm444 ${src} $out
      '';
in
{
  den.aspects.desktop.niri = {
    nixos = { pkgs, ... }: {
      programs.niri = {
        enable = true;
        package = niriPkgOf pkgs;
      };
    };

    hjem = { pkgs, ... }: {
      files.".config/niri/config.kdl" = {
        source = checkedConfig pkgs;
        clobber = true;
      };
    };
  };
}

