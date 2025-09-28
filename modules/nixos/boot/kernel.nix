{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) types mkOption mkOverride mapAttrsToList;
  inherit (lib.cauldron) hasProfile;
  cfg = config.cauldron.host.boot;
  
  defaultKernel = if (hasProfile config "gaming") then pkgs.linuxPackages_xanmod_latest
    else if (hasProfile config "workstation") then pkgs.linuxPackages_latest_hardened
    else if (hasProfile config "server") then pkgs.linuxPackages_hardened
    else if (hasProfile config "graphical") then pkgs.linuxPackages_xanmod
    else pkgs.linuxPackages_latest;
    
in {
  
  options.cauldron.host.boot = {
    kernel = mkOption {
      type = types.raw;
      default = defaultKernel;
      defaultText = "${defaultKernel}";
      description = "The kernel to use for the system.";
    };
  };
  
  config = {
    boot = {
      kernelPackages = mkOverride 500 cfg.kernel;
    };
  };
}
