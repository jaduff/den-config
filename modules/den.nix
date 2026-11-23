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


  den.aspects.default.includes = with den.aspects; [
    cli.vim
    tools.sudo
    tools.npins
    tools.git
];
  den.aspects.ignorant.includes = with den.aspects; [
    desktop.desktop-services
    desktop.niri
    desktop.dms
    desktop.kitty
    apps.telegram-desktop
  ];
}
