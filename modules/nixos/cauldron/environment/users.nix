{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.make.environment;
in {
  
  options.make.environment = {
    # TODO: Option expansion
  };

  config = {
    # No mutable users by default
    users.mutableUsers = mkForce false;
    # Allow root ssh key access
    users.users.root = mkIf pkgs.stdenv.isLinux {
      initialPassword = "changeme"; # TODO: Override via secrets
      openssh.authorizedKeys.keyFiles =  with inputs; [ my-keys.outPath ];
    };
  };
}