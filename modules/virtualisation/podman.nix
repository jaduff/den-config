# Podman aspect: rootless-by-default containers, with docker + docker-compose
# transparently backed by podman / podman-compose.
# Auto-imported by import-tree — do NOT add it to `imports` anywhere.
{ den, ... }:
{
  den.aspects.virtualisation.podman = {
    nixos =
      { pkgs, lib, ... }:
      {
        virtualisation = {
          podman = {
            enable = true;

            # `docker` becomes a symlink to `podman`, so `docker compose`
            # resolves to `podman compose` -> podman-compose (see below).
            dockerCompat = lib.mkDefault true;

            # Root-equivalent API sockets stay off; rootless needs neither.
            dockerSocket.enable = lib.mkDefault false;
            networkSocket.enable = lib.mkDefault false;

            autoPrune = {
              enable = lib.mkDefault true;
              dates = lib.mkDefault "weekly";
              flags = lib.mkDefault [ "--all" ];
            };

            # Puts podman-compose on the system PATH, where `podman compose`
            # looks for its provider.
            extraPackages = [ pkgs.podman-compose ];

          };

          containers = {
            enable = true;

            containersConf.settings = {
              containers = {
                no_new_privileges = lib.mkDefault true;

                # Docker's default set minus NET_RAW, MKNOD, AUDIT_WRITE.
                default_capabilities = lib.mkDefault [
                  "CHOWN"
                  "DAC_OVERRIDE"
                  "FOWNER"
                  "FSETID"
                  "KILL"
                  "NET_BIND_SERVICE"
                  "SETFCAP"
                  "SETGID"
                  "SETPCAP"
                  "SETUID"
                  "SYS_CHROOT"
                ];
              };

              engine = {
                events_logger = lib.mkDefault "journald";

                # Pin the compose provider to podman-compose. Without this,
                # `docker-compose` (the real one) wins by default if installed.
                compose_providers = lib.mkDefault [
                  "${pkgs.podman-compose}/bin/podman-compose"
                ];

                # Silence "executing external command" chatter.
                compose_warning_logs = lib.mkDefault false;
              };

            };
          };
        };

        # `docker-compose` (hyphenated) for scripts and legacy docs.
        # hiPrio shadows pkgs.docker-compose if it is also installed.
        environment.systemPackages = [
          (lib.hiPrio (
            pkgs.writeShellScriptBin "docker-compose" ''
              exec ${pkgs.podman-compose}/bin/podman-compose "$@"
            ''
          ))
        ];
      };
  };
}

