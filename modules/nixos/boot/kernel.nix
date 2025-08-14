{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkOption mkOverride;
  cfg = config.cauldron.host.boot;
in {
  options.cauldron.host.boot = {
    kernel = mkOption {
      type = types.raw;
      default = pkgs.linuxPackages_latest;
      defaultText = "pkgs.linuxPackages_latest";
      description = "The kernel to use for the system.";
    };
  };
  
  config = {
    boot = {
      kernelPackages = mkOverride 500 cfg.kernel;
    };
  };
}
