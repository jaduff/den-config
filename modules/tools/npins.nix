{
  den.aspects.tools.npins = {
    # system-wide: available to every shell for every user on the host
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.npins ];
    };

  };
}

