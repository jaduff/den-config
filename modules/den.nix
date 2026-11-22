{ den, lib, ... }:
{

  den.default = {
    nixos.system.nixos.tags = [ "den" ];
    includes = [
      den.aspects.tools.git
      den.aspects.nixpkgs
    ];
  };

  den.aspects.nixpkgs.nixos.nixpkgs.config.allowUnfree = true;

  den.aspects.ignorant.includes = [
    den.aspects.tools.sudo
    den.aspects.tools.git
  ];
}
