{ den, ... }:
{
  # your reusable package aspect (any file)
  den.aspects.my-packages = {
    nixos.environment.systemPackages = [ /* ... */ ];
    #homeManager.home.packages = [ /* ... */ ];
  };

  den.aspects.default.nixos.system.nixos.tags = ["den"];
  den.aspects.nixpkgs.os.nixpkgs.config.allowUnfree = true;
  den.aspects.ignorant.includes = with den.aspects; [
    tools.sudo

  ];
  den.schema.host.includes = [den.aspects.nixpkgs];
  # attach it to the host "igloo"
}

