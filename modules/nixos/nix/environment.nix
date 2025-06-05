{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in {
  config = {
    environment = {
      variables.NIXPKGS_CONFIG = mkForce "";
    };
  };
}
