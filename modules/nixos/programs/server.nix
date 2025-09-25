{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "server" profiles) {
    cauldron.packages = {
    		inherit (pkgs) iperf3 ethtool;
    };
  };
}
