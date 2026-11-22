# aspects/system/sops-nix.nix
{ inputs, ... }:
{
  den.aspects.sops-nix.nixos = { config, lib, pkgs, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    environment.systemPackages = with pkgs; [ sops ssh-to-age age ];

    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = lib.mkForce [
        "/etc/ssh/ssh_host_ed25519_key"
        "/home/jaduff/.ssh/id_ed25519"
      ];
    };
  };
}
