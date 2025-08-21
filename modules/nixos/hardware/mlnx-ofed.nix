{ lib, pkgs, config, sources, ...}:
let
  inherit (lib) types mkIf mkDefault mkOption;
  cfg = config.cauldron.host.feature;
in {
  imports = [
    ((import sources.mlnx-ofed).nixosModules.setupCacheAndOverlays)
    ((import sources.mlnx-ofed).nixosModules.default)
  ];
  
  options.cauldron.host.feature.mlnx-ofed = mkOption {
    type = types.bool;
    default = false;
    description = "Wether to enable Mellonox OFED tools";
  };
  
  config = mkIf cfg.mlnx-ofed {
    nixpkgs.overlays = [
      (import sources.mlnx-ofed).overlays.default
    ];
    
    boot = {
      extraModulePackages = [ config.boot.kernelPackages.mstflint_access ];
      kernelModules = [ "mstflint_access" ];
    };
    
    environment.systemPackages = with pkgs; [
      mstflint
    ];

    hardware.mlnx-ofed = {
      enable = true;
      fwctl.enable = true;
#      kernel-mft.enable = true;
    };
  };
}
