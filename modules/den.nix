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

  den.aspects.ignorant.includes = [
    den.aspects.tools.sudo
    den.aspects.tools.git
  ];
}
