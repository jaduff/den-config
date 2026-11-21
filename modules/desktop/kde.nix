# modules/desktop/kde.nix
{ den, pkgs, ... }:
{
  den.aspects.kde = {
    nixos = {
      # the desktop itself (default: false)
      services.desktopManager.plasma6.enable = true;

      # pick ONE display manager — see below
      services.displayManager.plasma-login-manager.enable = true;

      # optional: trim the default app set
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        plasma-browser-integration
      ];

};
  };
}

