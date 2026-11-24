# modules/gaming/steam.nix
{ den, ... }:
{
  den.aspects.gaming.steam.nixos = { pkgs, ... }: {
    programs.steam = {
      enable = true;

      # replaces every hand-written port line in your old default.nix
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;

      # niri is Wayland: Steam Input needs this to see controllers
      extest.enable = true;

      # installs protontricks *wired to Steam's compat tools*
      protontricks.enable = true;

      extraCompatPackages = [ pkgs.proton-ge-bin ];

      extraPackages = with pkgs; [ gamescope mangohud ];
    };

    programs.gamemode.enable = true;

    # winetricks has no module option — it is just the package
    environment.systemPackages = with pkgs; [
      winetricks
      protonup-qt                 # manual Proton management, optional
      (pkgs.wineWow64Packages.stable or pkgs.wineWow64Packages.full)
    ];

    # your GameCube controller udev line, kept
    services.udev.packages = [ pkgs.dolphin-emu ];
  };
}

