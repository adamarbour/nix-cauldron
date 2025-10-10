{ lib, pkgs, config, sources, ...}:
let
  inherit (lib) attrValues mkIf;
  inherit (lib.cauldron) hasProfile;
in {
  imports = [ (import sources.stylix).nixosModules.stylix ];
  config = mkIf (hasProfile "graphical" config) {
    stylix = {
      enable = true;
    };
  };
}
