{ den, ...}:
{
  den.aspects.tools.btop.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [ btop ];
  };
}
