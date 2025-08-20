{ lib, pkgs, config, ...}:
let
  inherit (lib) mkMerge mkIf filterAttrs;
  hasBtrfs = (filterAttrs (_: v: v.fsType == "btrfs") config.fileSystems) != { };
  hasZfs = (filterAttrs (_: v: v.fsType == "zfs") config.fileSystems) != { };
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
    
    # clean zfs devices
    (mkIf hasZfs {
      services.zfs = {
        trim = {
          enable = true;
          interval = "weekly";
        };
        autoScrub = {
          enable = true;
          interval = "monthly";
        };
      };
    })
  ];
}
