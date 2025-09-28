{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) types mkOption mkOverride;
  inherit (lib.cauldron) hasProfile;
  cfg = config.cauldron.host.boot;
  chaotic = (import sources.flake-compat { src = sources.chaotic-nyx; }).outputs;
  defaultKernel = if (hasProfile config "gaming") then pkgs.linuxPackages_cachyos-gcc
    else if (hasProfile config "workstation") then pkgs.linuxPackages_cachyos-hardened
    else if (hasProfile config "server") then pkgs.linuxPackages_cachyos-server
    else if (hasProfile config "graphical") then pkgs.linuxPackages_cachyos-lts
    else pkgs.linuxPackages_latest;
in {
  imports = [
    chaotic.nixosModules.nyx-cache
    chaotic.nixosModules.nyx-overlay
    chaotic.nixosModules.nyx-registry
  ];
  
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
