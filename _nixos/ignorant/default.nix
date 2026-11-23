{
  pkgs,
  config,
  lib,
  channel,
  ...
}:
with lib;
with lib; {
  imports = [./hardware.nix];

  # Resolve an issue with Bismuth's wired connections failing sometimes due to weird
  # DHCP issues. I'm not quite sure why this is the case, but I have found that the
  # problem can be resolved by stopping dhcpcd, restarting Network Manager, and then
  # unplugging and replugging the ethernet cable. Perhaps there's some weird race
  # condition when the system is coming up that causes this.
  # networking.dhcpcd.enable = false;

nix.settings.trusted-substituters = ["https://ai.cachix.org"];
nix.settings.trusted-public-keys = ["ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="];
services.ntp.enable = true;



  # Enable cross-building on the pi
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];



  boot.supportedFilesystems = [ "ntfs" ];
  boot.plymouth.enable = true;
  boot.plymouth.theme = "breeze";
  environment.systemPackages = with pkgs; [
    plymouth
    kdePackages.breeze-plymouth
    #intel-gpu-tools
    dive
    podman-tui
    podman-compose
    #plusultra.kalidoface
  ];
virtualisation.libvirtd.enable = true;
#  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # NOTE: This _may_ be required for openvpn to work. However, I have
  # not confirmed that...
#  boot.kernelModules = ["tun"];



  # WiFi is typically unused on the desktop. Enable this service
  # if it's no longer only using a wired connection.
  #systemd.services.network-addresses-wlp41s0.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
