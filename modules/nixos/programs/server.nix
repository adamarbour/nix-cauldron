{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf;
  inherit (lib.cauldron) hasProfile;
in {
  config = mkIf (hasProfile config "server") {
    cauldron.packages = {
    		inherit (pkgs) iperf3 ethtool;
    };
  };
}
