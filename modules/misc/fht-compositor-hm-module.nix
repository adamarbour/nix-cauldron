# Workaround wrapper to pass in a dummy flake...
{ lib, pkgs, sources, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  packages = (import sources.fht-compositor) { inherit pkgs; };
  self = {
    packages.${system}.fht-compositor = pkgs.callPackage "${sources.fht-compositor}/nix/packages.nix" {};
  };
  wrapper = (import "${sources.fht-compositor}/nix/hm-module.nix") { inherit self; };
in wrapper.flake.homeModules.fht-compositor
