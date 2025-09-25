{ lib, pkgs, sources, ... }:
let
  flakeCompat = (import sources.flake-compat { src = sources.mangowc; }).defaultNix;
in {
  imports = [ flakeCompat.hmModules.mango ];
}
