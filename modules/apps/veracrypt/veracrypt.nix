{ den, ... }:
{
  den.aspects.apps.veracrypt = {
    meta.description = "VeraCrypt, system-wide with hardened defaults";

    nixos = { pkgs, ... }:
      let
        seed = pkgs.writeShellScript "veracrypt-seed-config" ''
          set -eu
          d="$HOME/.config/VeraCrypt"
          ${pkgs.coreutils}/bin/mkdir -p "$d"
          ${pkgs.coreutils}/bin/install -m 0600 ${./veracrypt-config.xml} "$d/Configuration.xml"
        '';
      in
      {
        environment.systemPackages = [ pkgs.veracrypt ];

        systemd.user.services.veracrypt-config = {
          description = "Seed VeraCrypt secure defaults";
          wantedBy = [ "default.target" ];
          unitConfig.ConditionPathExists = "!%h/.config/VeraCrypt/Configuration.xml";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = seed;
          };
        };
      };
  };
}
