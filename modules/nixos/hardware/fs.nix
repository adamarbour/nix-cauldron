{ lib, pkgs, config, ...}:
let
  inherit (lib) mkMerge mkIf filterAttrs;
  hasBtrfs = (filterAttrs (_: v: v.fsType == "btrfs") config.fileSystems) != { };
in {
  config = mkMerge [
    {
      services.fstrim = {
        enable = true;
        interval = "weekly";
      };
    }
    
    # clean btrfs devices
    (mkIf hasBtrfs {
      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
      };
    })
  ];
}
