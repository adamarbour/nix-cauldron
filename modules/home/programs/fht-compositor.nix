{ lib, pkgs, sources, ... }:
let
  flakeCompat = (import sources.flake-compat { src = sources.fht-compositor; }).defaultNix;
in {
  imports = [ flakeCompat.homeModules.fht-compositor ];
}
