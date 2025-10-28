{ lib, pkgs, sources, ... }:
let
  flakeCompat = (import sources.flake-compat { src = sources.vicinae; }).defaultNix;
in {
  imports = [ flakeCompat.homeManagerModules.default ];
  
  config = {
    services.vicinae = {
      enable = true;
      autoStart = true;
    };
  };
}
