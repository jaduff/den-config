# oterm aspect: package-only tool, ephemeral state, local Ollama only.
# Auto-imported by import-tree — do NOT add it to `imports` anywhere.
{ den, ... }:
{
  den.aspects.ai.oterm = {
    # Uncomment if every host with oterm should also carry the server.
    # includes = [ den.aspects.ai.ollama ];

    hjem =
      { pkgs, lib, ... }:
      let
        # Workaround for an upstream postInstall race: the three
        # `_OTERM_COMPLETE` invocations run concurrently, all miss
        # config.json, and one reads it while another has truncated it to
        # zero bytes. AppConfig only catches FileNotFoundError, so the empty
        # file is a fatal JSONDecodeError and the completion file ends up
        # missing -> "installShellCompletion: ... does not exist or has zero
        # size". Seeding a valid config before the completions run means
        # nobody takes the save() branch.
        #
        # preBuild already exists in the derivation to provide a scratch
        # HOME; exports made here persist into installPhase.
        oterm = pkgs.oterm.overrideAttrs (old: {
          preBuild = (old.preBuild or "") + ''
            export OTERM_DATA_DIR="$(mktemp -d)"
            printf '{}' > "$OTERM_DATA_DIR/config.json"
          '';
        });

        # Providers oterm auto-discovers from the environment at startup.
        # A provider only appears in the new-chat dropdown when its required
        # vars are present, so unsetting them removes the entry outright.
        remoteKeys = [
          "OPENAI_API_KEY"
          "ANTHROPIC_API_KEY"
          "GOOGLE_API_KEY"
          "GOOGLE_APPLICATION_CREDENTIALS"
          "GROQ_API_KEY"
          "MISTRAL_API_KEY"
          "COHERE_API_KEY"
          "AWS_ACCESS_KEY_ID"
          "AWS_SECRET_ACCESS_KEY"
          "DEEPSEEK_API_KEY"
          "GROK_API_KEY"
          "CEREBRAS_API_KEY"
          "HF_TOKEN"
          "OLLAMA_API_KEY" # unlocks ollama.com cloud models
          "OPENROUTER_API_KEY" # not auto-discovered; read via ${VAR} in config.json
        ];

        otermPrivate = pkgs.writeShellScriptBin "oterm" ''
          set -eu

          # Pin the endpoint to loopback so a stray OLLAMA_URL can't
          # silently redirect chats to a remote host. A deliberate
          # override still wins ("-" keeps it if already set).
          export OLLAMA_HOST="''${OLLAMA_HOST:-127.0.0.1:11434}"
          export OLLAMA_URL="''${OLLAMA_URL:-http://$OLLAMA_HOST}"

          # No cloud, no third-party providers, unless explicitly opted in.
          if [ "''${OTERM_ALLOW_REMOTE:-0}" != "1" ]; then
            unset ${lib.concatStringsSep " " remoteKeys}
          fi

          # Ephemeral state: store.db, memory.db, saved logs and
          # downloads/ live on tmpfs and vanish at logout.
          # For persistent history, drop this block (falls back to
          # ~/.local/share/oterm).
          if [ -n "''${OTERM_DATA_DIR:-}" ]; then
            data_dir="$OTERM_DATA_DIR"
          elif [ -n "''${XDG_RUNTIME_DIR:-}" ]; then
            data_dir="$XDG_RUNTIME_DIR/oterm"
          else
            data_dir="$(mktemp -d "''${TMPDIR:-/tmp}/oterm.XXXXXX")"
          fi
          mkdir -p "$data_dir"
          chmod 700 "$data_dir"
          export OTERM_DATA_DIR="$data_dir"

          exec ${oterm}/bin/oterm "$@"
        '';
      in
      {
        # hjem.users.<name>.packages -> users.users.<name>.packages, i.e. a
        # per-user profile at /etc/profiles/per-user/<name>. The wrapper
        # embeds the patched oterm, so do NOT also list pkgs.oterm here --
        # two bin/oterm in one profile is a collision.
        packages = [ otermPrivate ];
      };
  };
}

