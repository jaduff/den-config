{ den, inputs, ... }:
{
  # we can import this flakeModule even if we dont have flake-parts as input!
  imports = [ inputs.den.flakeModule ];


  # include den batteries or your own re-usable aspects
  # this affects all users, could also be done per user
  den.schema.user.includes = [ den.batteries.define-user ];

  # user aspect
  den.aspects.jaduff= {
    # user configures host <nixos/darwin>.users.users.tux.description
    # Read docs about the `user` class.
    user.description = "Cute Penguin";
    user.extraGroups = ["wheel" "docker" "networkmanager" "audio"];

    # user contributes nixos and darwin common config
    os =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.vim pkgs.librewolf];
      };

    hjem.files.".foo".text = "bar";
  };

}
