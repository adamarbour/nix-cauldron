{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) types mkOption mkOverride mapAttrsToList;
  inherit (lib.cauldron) hasProfile;
  cfg = config.cauldron.host.boot;
  chaotic = (import sources.flake-compat { src = sources.chaotic-nyx; }).outputs;
  
  defaultKernel = if (hasProfile config "gaming") then pkgs.linuxPackages_xanmod_latest
    else if (hasProfile config "workstation") then pkgs.linuxPackages_latest_hardened
    else if (hasProfile config "server") then pkgs.linuxPackages_hardened
    else if (hasProfile config "graphical") then pkgs.linuxPackages_xanmod_stable
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
      default = pkgs.linuxPackages_latest;
      defaultText = "${defaultKernel}";
      description = "The kernel to use for the system.";
    };
  };
  
  config = {
    boot = {
      kernelPackages = mkOverride 500 cfg.kernel;
      # We like the bore scheduler...
      kernelPatches = let
        patchesDir = "${sources.bore}/patches/stable/linux-${lib.versions.majorMinor config.boot.kernelPackages.kernel.version}-bore";
      in lib.optionals (hasProfile config "gaming") (
        mapAttrsToList (name: _: {
          name = "bore-${name}";
          patch = "${patchesDir}/${name}";
        }) (builtins.readDir patchesDir)
      );
    };
  };
}
