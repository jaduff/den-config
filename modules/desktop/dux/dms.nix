{ den, ... }:
let
  # Freeform JSON, merged over settings.json. Verify keys first:
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
        enable = true;              # package defaults to pkgs.dms-shell
        systemd.enable = true;
        systemd.restartIfChanged = true;
        enableVPN = falst;
        enableSystemMonitoring = true;
        enableDynamicTheming = true;
        enableAudioWavelength = true;
        # enableCalendarEvents = true;  # pulls in khal
      };
    };

    hjem = _: {
      files.".config/dms/config.d/00-nix.json" = {
        text = builtins.toJSON dmsSettings;
        clobber = true;
      };
    };
  };
}
