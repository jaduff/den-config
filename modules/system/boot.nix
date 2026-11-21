# modules/system/boot.nix   (loaded by import-tree)
{ den, lib, ... }:
{
  den.aspects.system.boot = {
        boot.loader.systemd-boot.enable = true;
        boot.loader.systemd-boot.configurationLimit = 10;
        boot.loader.efi.canTouchEfiVariables = true;

        boot.loader.systemd-boot.editor = false;
  };
}

