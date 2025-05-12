{ lib, config, pkgs, inputs, ... }:
{
  config = {
    nixpkgs.config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      allowBroken = false;
      permittedInsecurePackages = [ ];
      allowUnsupportedSystem = false;
      allowAliases = false;
    };
    nixpkgs.overlays = [
      (final: _prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (pkgs.stdenv.hostPlatform) system;
          inherit (config.nixpkgs) config;
        };
      })
    ];
  };
}