# modules/system/sudo.nix   (loaded by import-tree)
{ den, ... }:
{
  den.aspects.tools.sudo.nixos = {
    security.sudo.enable = true;
    security.sudo.wheelNeedsPassword = true;   # default; keep it
    security.sudo.execWheelOnly = true;        # sudo binary is 0750 root:wheel
  };

}

