{ den, ...}:
{
  den.aspects.tools.nvtop.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [ nvtopPackages.nvidia ];
  };
}
