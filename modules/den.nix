{ den, ... }:
{
  # your reusable package aspect (any file)
  den.aspects.my-packages = {
    nixos.environment.systemPackages = [ /* ... */ ];
    homeManager.home.packages = [ /* ... */ ];
  };

  system.nixos.tags = ["denful"];
  # attach it to the host "igloo"
}

