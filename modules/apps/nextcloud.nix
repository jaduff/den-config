# modules/apps/nextcloud.nix
{ den, ... }:
{
  # the user half, reusable
  den.aspects.apps.nextcloud-hjem.hjem = { pkgs, ... }: {
    packages = [
      pkgs.nextcloud-client
      pkgs.nextcloud-talk-desktop
    ];
  };

  # the system half
  den.aspects.apps.nextcloud.nixos = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.nextcloud-client ];
  };

  # ignorant gets the system package...
  den.aspects.ignorant.includes = [ den.aspects.apps.nextcloud ];

  # ...and only these users get the hjem part, only on ignorant
  den.aspects.ignorant.provides.jaduff.hjem = den.aspects.apps.nextcloud-hjem.hjem;
}
