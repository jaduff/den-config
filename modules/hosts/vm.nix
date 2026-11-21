{ den, inputs, ... }:
{
  # we can import this flakeModule even if we dont have flake-parts as input!
  imports = [ inputs.den.flakeModule ];

  den.default.nixos = {
    # remove for real host
    #fileSystems."/".device = "/dev/fake";
    #fileSystems."/".fsType = "auto";
    #boot.loader.grub.enable = false;
    system.stateVersion = "21.11";
  };

  den.hosts.x86_64-linux.vm.users = {
    jaduff.classes = [ "hjem" ];
  };

  # first: `npins add -n darwin github nix-darwin nix-darwin`
  # den.hosts.aarch64-darwin.apple.users.tux.classes = [ "hjem" ];

  # host aspect
  den.aspects.vm= {
    nixos =
      { pkgs, ... }:
      {
        virtualisation.vmVariant ={
	  virtualisation = {
	    memorySize  = 8192;
	    cores = 8;
	    graphics = true;
	  };
	};
	users.users.jaduff.initialPassword = "test";
	security.sudo.wheelNeedsPassword = false;
        environment.systemPackages = [
          pkgs.vim
        ];
      };
      includes = [den.aspects.apps.firefox den.aspects.desktop.hyprland];
  };

}
