# Ollama aspect: loopback-only, no cloud, CUDA when the host has it.
{ den, pkgs, ... }:
{
  den.aspects.ai.ollama = {
    nixos =
      { lib, pkgs, config, ... }:
      {
        services.ollama = {
          enable = true;

          # Without this you get the CPU-only build and ollama silently
          # falls back to CPU. mkDefault so a ROCm/Vulkan host can override.
          package = lib.mkDefault pkgs.ollama-cuda;

          host = lib.mkDefault "127.0.0.1";
          openFirewall = lib.mkDefault false;

          loadModels = lib.mkDefault [ ];
          syncModels = lib.mkDefault false;

          environmentVariables = {
            OLLAMA_NO_CLOUD = lib.mkDefault "1";   # real knob: envconfig.NoCloudEnv
            OLLAMA_DEBUG = lib.mkDefault "0";      # set "1" while debugging GPU probing
            OLLAMA_KEEP_ALIVE = lib.mkDefault "5m";
          };
        };

        systemd.services.ollama.serviceConfig = lib.mkIf config.services.ollama.enable {
          # Leave stdout alone: the GPU detection lines are the whole diagnosis.
          # StandardOutput = lib.mkDefault "null";
          StandardError = lib.mkDefault "journal";
        };
      };
  };
}

