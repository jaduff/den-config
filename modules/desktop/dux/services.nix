{ den, lib, ... }:
{
  den.aspects.desktop.desktop-services = {
    nixos = { pkgs, ... }: {
      # --- session entry point -------------------------------------------
      # programs.niri adds niri to services.displayManager.sessionPackages,
      # but without a display manager nothing ever shows a login prompt.
      services.greetd = {
        enable = true;
        settings = {
          default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
          # Uncomment for a kiosk-style autologin instead of the prompt:
          # initial_session = { command = "${pkgs.niri}/bin/niri-session"; user = "jaduff"; };
        };
      };
      services.displayManager.defaultSession = "niri";

      # --- audio / screencast --------------------------------------------
      # niri screencasting goes through xdg-desktop-portal-gnome + pipewire;
      # without pipewire the ScreenCast interface just fails at request time.
      services.pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        alsa.support32Bit = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
      };
      services.pulseaudio.enable = lib.mkDefault false;

      security.rtkit.enable = true;

      # --- hardware / desktop services ------------------------------------
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General.Experimental = true;
      };

      networking.networkmanager.enable = true;

      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
      security.polkit.enable = true;
      programs.dconf.enable = true;

      # programs.niri already mkDefault-enables this; explicit for clarity.
      services.gnome.gnome-keyring.enable = true;

      # --- portals ---------------------------------------------------------
      # Do NOT set xdg.portal.config.common here. programs.niri defines
      # xdg.portal.config.niri = { default = [ "gnome" "gtk" ]; ... } and
      # extraPortals = [ xdg-desktop-portal-gnome ]. A "common" default of
      # gtk would make gtk the fallback everywhere else and silently drop
      # the gnome backend that screencasting depends on.
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk    # fallback: file chooser, access, open-uri
          xdg-desktop-portal-gnome  # screencast (also pulled in by programs.niri)
        ];
        xdgOpenUsePortal = true;    # fixes xdg-open inside flatpak/sandboxes
      };

      # --- environment ------------------------------------------------------
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        TERMINAL = "kitty";
        # QT_QPA_PLATFORMTHEME = "gtk3";  # only with the Qt6 gtk platform-theme
                                          # plugin installed; DMS themes Qt itself,
                                          # so this is usually unnecessary now.
      };

      # --- CLI tools --------------------------------------------------------
      environment.systemPackages = with pkgs; [
        ghostty
        xwayland-satellite # niri auto-starts it when it's on PATH
        swappy
        brightnessctl
        playerctl
        wl-clipboard
        #blueman
        #networkmanagerapplet
      ];
    };
  };
}

