{ lib, pkgs, config, ... }:
let
  inherit (lib) elem mkIf mkMerge mkDefault;
  enableUser = (elem "aarbour" config.cauldron.host.users);
in {
  config = mkIf enableUser {
    users.users.aarbour = {
      description = "Adam Arbour";
    };
  };
}
