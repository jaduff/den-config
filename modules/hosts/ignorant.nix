{ den, inputs, ... }:
{
  # we can import this flakeModule even if we dont have flake-parts as input!
  imports = [ inputs.den.flakeModule ];

  den.default.nixos = {
    # remove for real host
    fileSystems."/".device = "/dev/fake";
    fileSystems."/".fsType = "auto";
    boot.loader.grub.enable = false;
    system.stateVersion = "21.11";
  };

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
        environment.systemPackages = [
          pkgs.vim
        ];
      };
  };

}
