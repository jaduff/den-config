{ den, lib, ... }:
{

  den.default = {
    nixos.system.nixos.tags = [ "den" ];
    includes = with den.aspects; [
      tools.git
      nixpkgs
      tools.direnv
      cli.vim
      tools.sudo
      tools.npins
      virtualisation.podman
    ];
  };

  den.aspects.nixpkgs.nixos.nixpkgs.config.allowUnfree = true;


  den.aspects.ignorant.includes = with den.aspects; [
    desktop.desktop-services
    desktop.niri
    desktop.dms
    desktop.kitty
    apps.telegram-desktop
    apps.veracrypt
    ai.ollama
    ai.oterm
  ];
}
