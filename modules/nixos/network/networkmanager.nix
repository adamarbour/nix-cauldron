{ lib, ... }:
let
  inherit (lib) mkForce;
in {
  networking.networkmanager = {
    enable = mkForce false;
  };
}
