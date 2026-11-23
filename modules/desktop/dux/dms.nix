{ den, ... }:
let
  # Freeform JSON, merged over settings.json by Dux. Verify keys first:
  #   dms ipc call settings get showSeconds
  dmsSettings = {
    showSeconds = true;
    barElevationEnabled = true;
  };
in
{
  den.aspects.desktop.dms = {
    nixos = {
      programs.dms-shell = {
        enable = true; # package defaults to pkgs.dms-shell

        systemd = {
          enable = true; # start with the session (this is the default)
          restartIfChanged = true;
          target = "niri.service"; # bind to niri, not graphical-session.target
        };

        # feature toggles (all valid options at nixpkgs 26.05pre980800)
        enableVPN = true; # this is already the default
        enableSystemMonitoring = true;
        enableDynamicTheming = true;
        enableAudioWavelength = true;
        # enableCalendarEvents = true;  # pulls in khal
      };
    };

    hjem = _: {
      # verify Dux still reads config.d/ as a drop-in dir on your version;
      # some releases use ~/.config/DankMaterialShell/ instead of ~/.config/dms/
      files.".config/dms/config.d/00-nix.json" = {
        text = builtins.toJSON dmsSettings;
        clobber = true;
      };
    };
  };
}

