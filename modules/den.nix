{ den, lib, ... }:
{

  den.default = {
    nixos.system.nixos.tags = [ "den" ];
    includes = with den.aspects; [
      tools.git
      nixpkgs
      tools.direnv
    ];
  };

  den.aspects.nixpkgs.nixos.nixpkgs.config.allowUnfree = true;

  den.aspects.ignorant.includes = with den.aspects; [
    tools.sudo
    tools.git
    desktop.desktop-services
    desktop.niri
    desktop.dms
    desktop.kitty
  ];
}
