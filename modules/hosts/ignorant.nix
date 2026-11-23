{ den, inputs, ... }:
{
  # we can import this flakeModule even if we dont have flake-parts as input!
  imports = [ inputs.den.flakeModule ];


  den.hosts.x86_64-linux.ignorant.users = {
    jaduff.classes = [ "user" "hjem" ];
  };

  # first: `npins add -n darwin github nix-darwin nix-darwin`
  # den.hosts.aarch64-darwin.apple.users.tux.classes = [ "hjem" ];

  # host aspect
  den.aspects.ignorant= {
    nixos =
      { pkgs, ... }:
      {
        imports = [ ../../_nixos/ignorant/default.nix ];
	# NETWORKING
	networking.networkmanager.enable = true;
	networking.hostName = "ignorant";
        system.stateVersion = "21.11";
	# BOOT
	  # Enable cross-building on the pi
	boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
	boot.initrd.systemd.enable = true;
	boot.supportedFilesystems = [ "ntfs" ];
	boot.plymouth.enable = true;
	boot.plymouth.theme = "breeze";
	virtualisation.libvirtd.enable = true;
	#  boot.binfmt.emulatedSystems = ["aarch64-linux"];
        environment.systemPackages = with pkgs; [
	    networkmanagerapplet
	    plymouth
	    kdePackages.breeze-plymouth
	    dive
	    podman-tui
	    podman-compose
        ];

      };
    includes = with den.aspects; [ 
    apps.firefox
    system.boot
    ];
  };

}
