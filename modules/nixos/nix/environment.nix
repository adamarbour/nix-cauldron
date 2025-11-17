{ lib, pkgs, ... }:
let
  inherit (lib) mkForce;
in {
  environment.variables = {
    NIX_PATH = mkForce "nixpkgs=${pkgs.path}";
    NIXPKGS_CONFIG = mkForce "";
    NIX_REMOTE = "daemon";
  };
}
