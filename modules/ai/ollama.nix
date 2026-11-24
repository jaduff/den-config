# Ollama aspect: loopback-only, no cloud.
# Auto-imported by import-tree — do NOT add it to `imports` anywhere.
{ den, ... }:
{
  den.aspects.ai.ollama = {
    nixos =
      { lib, config, ... }:
      {
        services.ollama = {
          enable = true;

          # Loopback only. Already the module default; pinned so a host-level
          # override has to be explicit rather than accidental.
          host = lib.mkDefault "127.0.0.1";
          openFirewall = lib.mkDefault false;

          # No declarative pulls: nothing leaves the box at boot, and every
          # model arrives via an explicit, auditable `ollama pull`.
          loadModels = lib.mkDefault [ ];
          syncModels = lib.mkDefault false;

          environmentVariables = {
            OLLAMA_NO_CLOUD = lib.mkDefault "1";
            OLLAMA_DEBUG = lib.mkDefault "0";
            # OLLAMA_DEBUG_LOG_REQUESTS deliberately absent.
            OLLAMA_KEEP_ALIVE = lib.mkDefault "5m";
          };
        };

        systemd.services.ollama.serviceConfig = lib.mkIf config.services.ollama.enable {
          StandardOutput = lib.mkDefault "null";
          # StandardError = lib.mkDefault "null";

          # IPAddressDeny = "any";
          # IPAddressAllow = "localhost";
        };
      };
  };
}

