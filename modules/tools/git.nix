{ den, ... }:
let
  me = {
    name = "James Duff";
    email = "jaduff@protonmail.com";
    signingKey = "D2BD9504976B2E1A";
  };
  signCommits = true;
in
{
  den.aspects.tools.git = {
    hjem = { pkgs, lib, ... }: {
      # git/gh land in users.users.<name>.packages
      packages = with pkgs; [ git gh git-lfs ];

      # ~/.config/git/config
      xdg.config.files."git/config" = {
        generator = lib.generators.toGitINI;
        value = {
          user = {
            inherit (me) name email;
            signingkey = me.signingKey;
          };

          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;

          commit.gpgsign = signCommits;
          tag.gpgsign = signCommits;

          core.whitespace = "trailing-space,space-before-tab";
          safe.directory = [ "~/work/config" ];

          url."ssh://git@github.com/".insteadOf = "https://github.com/";

          # what `programs.git.lfs.enable` used to write for you
          filter."lfs" = {
            clean = "git-lfs clean -- %f";
            smudge = "git-lfs smudge -- %f";
            process = "git-lfs filter-process";
            required = true;
          };
        };
      };
    };
  };
}
