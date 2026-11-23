{ den, ... }:
{
  den.aspects.desktop.desktop-services = {
    nixos = { pkgs, ... }: {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General.Experimental = true;
      };

      networking.networkmanager.enable = true;

      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
      security.polkit.enable = true;
      services.gnome.gnome-keyring.enable = true;
      programs.dconf.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = [ "gtk" ];
      };

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_QPA_PLATFORMTHEME = "gtk3";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        TERMINAL = "ghostty";
      };

      # CLI tools: system-level so they're on PATH regardless of class wiring.
      environment.systemPackages = with pkgs; [
        ghostty
        xwayland-satellite
        swappy
        brightnessctl
        playerctl
        wl-clipboard
        blueman               # one-off BT pairing GUI
        networkmanagerapplet  # one-off wifi/VPN profiles
      ];
    };
  };
}

