{ den, ... }:
{
  den.aspects.tools.git = {
    hjem = { pkgs, lib, ... }: {
      # git/gh land in users.users.<name>.packages
      packages = with pkgs; [ git gh ];

      # ~/.config/git/config
      xdg.config.files."git/config" = {
        generator = lib.generators.toGitINI;
        value = {
          user = {
            name = "James Duff";
            email = "jaduff@protonmail.com";
          };
          init.defaultBranch = "main";
          pull.rebase = true;
          url."ssh://git@github.com/".insteadOf = "https://github.com/";
        };
      };
    };
  };
}
