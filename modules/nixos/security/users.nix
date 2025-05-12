{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkIf mkDefault;

  cfg = config.cauldron.security;
in {
  config = {
    # No mutable users by default
    users = {
      mutableUsers = mkDefault false;
      users."root" = {
        initialPassword = "nixos";
        hashedPasswordFile = config.sops.secrets.my_password.path;
        openssh.authorizedKeys.keyFiles = with inputs; [ my-keys.outPath ];
      };
    };
  };
}