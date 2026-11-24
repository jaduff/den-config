# modules/desktop/hyprland.nix   (picked up by import-tree)
{ den, inputs, ... }:
{
  den.aspects.desktop.hyprland.hjem.xdg.config.files = {

    "hypr/hyprland.lua" = {
      source  = ./hyprland_config/hyprland.lua;
      clobber = true;   # Hyprland regenerates this on boot if absent
    };

    "waybar/config.jsonc" = {
      source  = ./hyprland_config/waybar.jsonc;
      clobber = true;
    };

    "waybar/style.css" = {
      source  = ./hyprland_config/waybar.css;
      clobber = true;
    };

    "fuzzel/fuzzel.ini" = {
      source  = ./hyprland_config/fuzzel.ini;
      clobber = true;
    };

  };

  den.aspects.desktop.hyprland = {
    nixos = { pkgs, ... }: {
       nixpkgs.overlays = [
         (final: _prev: {
           unstable = import inputs."unstable" {
             inherit (final.stdenv.hostPlatform) system;
             inherit (final) config;
           };
         })
       ];
   
      programs.hyprland = {
        enable = false;
	package = pkgs.unstable.hyprland;
	portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
        withUWSM = true;              # implies programs.uwsm.enable
        xwayland.enable = true;       # already the option default
      };

      # Everything else (session entry, portals, rtkit, uwsm) the module handles.

      environment.systemPackages = with pkgs; [
        # session / bar / launcher
        waybar
        fuzzel
        kitty

        # fonts — waybar and fuzzel need a Nerd Font for their glyphs
        nerd-fonts.jetbrains-mono
        noto-fonts

        # first-party tools, optional — delete what you don't use
        hyprpaper
        hyprlock
        hypridle

        # utilities the dotfiles will assume exist
        grim
        slurp
        wl-clipboard
        cliphist
        playerctl
        brightnessctl
        pavucontrol
      ];
    };
  };
}

