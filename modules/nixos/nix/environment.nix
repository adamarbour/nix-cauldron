{ lib, pkgs, ... }:
let
  inherit (lib) mkForce;
in {
  environment.variables.NIX_PATH = mkForce "nixpkgs=${pkgs.path}";
  environment.variables.NIXPKGS_CONFIG = mkForce "";
}
