{ den, ...}:
{
  den.aspects.apps.libreoffice.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [ libreoffice ];
  };
}
