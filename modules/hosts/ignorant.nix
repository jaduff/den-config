{ den, inputs, ... }:
{
  # we can import this flakeModule even if we dont have flake-parts as input!
  imports = [ inputs.den.flakeModule ];


  den.hosts.x86_64-linux.ignorant.users = {
    jaduff.classes = [ "hjem" ];
    nixos.imports = [ ../../_nixos/gnorant/hardware.nix ];
  };

  # first: `npins add -n darwin github nix-darwin nix-darwin`
  # den.hosts.aarch64-darwin.apple.users.tux.classes = [ "hjem" ];

  # host aspect
  den.aspects.ignorant= {
    nixos =
      { pkgs, ... }:
      {
        system.stateVersion = "21.11";
        environment.systemPackages = [
          pkgs.vim
        ];
      };
    includes = [ den.aspects.apps.firefox den.aspects.desktop.hyprland];
  };

}
