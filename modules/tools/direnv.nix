# aspects/direnv.nix
{ ... }:
{
  den.aspects.tools.direnv = {
    hjem = { pkgs, ... }: {
      packages = with pkgs; [ direnv nix-direnv sops ssh-to-age age ];

      # makes `use flake` work in .envrc files
      files.".config/direnv/direnvrc".source =
        "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
    };

    # the hook: must come from the shell, so it lives in the nixos class
    nixos = { pkgs, ... }: {
      programs.bash.interactiveShellInit = ''
        eval "$(${pkgs.direnv}/bin/direnv hook bash)"
      '';
      programs.zsh.interactiveShellInit = ''
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      '';
    };
  };
}
