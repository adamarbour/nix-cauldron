{ lib, config, sources, ...}:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.disk;
in {
  config = mkIf (cfg.enable && cfg.rootFs == "zfs") {
    # TMPFS for impermanence
    disko.devices.nodev = mkIf cfg.impermanence.enable {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [ "defaults" "size=${cfg.impermanence.rootSize}" "mode=755" ];
      };
    };
    
    # PRIMARY disk
    disko.devices.disk.disk0 = let
      rootfsContent = {
        type = "zfs";
        pool = "zroot";
      };
    in {
      type = "disk";
      device = cfg.device;
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02"; # for grub MBR
            priority = 100;
          };
          esp = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            priority = 1000;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          rootfs = {
            end = if cfg.swap.enable
              then "-${cfg.swap.size}"
              else "-0";
            content = if cfg.encrypt then {
              type = "luks";
              name = "enc";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };
              content = rootfsContent;
            } else rootfsContent;
          };
          swap = mkIf cfg.swap.enable {
            size = "100%";
            priority = 3000;
            content = {
              type = "swap";
              randomEncryption = cfg.encrypt;
              resumeDevice = cfg.swap.resume;
            };
          };
        };
      };
    };
    
    # ZROOT
    disko.devices.zpool.zroot = {
      type = "zpool";
      rootFsOptions = {
        acltype = "posixacl";
        compression = "zstd";
        atime = "off";
        xattr = "sa";
        mountpoint = "none";
        "com.sun:auto-snapshot" = "false";
      };
      options.ashift = "12";
      datasets = {
        "local" = {
          type = "zfs_fs";
          options.mountpoint = "none";
        };
        "local/rootfs" = mkIf (!cfg.impermanence.enable) {
          type = "zfs_fs";
          mountpoint = "/";
          options."com.sun:auto-snapshot" = "false";
          postCreateHook = ''
            zfs list -t snapshot -H -o name | grep -E '^zroot/local/rootfs@blank$' || zfs snapshot zroot/local/rootfs@blank
          '';
        };
        "local/nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options."com.sun:auto-snapshot" = "false";
        };
        "local/persist" = mkIf (cfg.impermanence.enable) {
          type = "zfs_fs";
          mountpoint = "/persist";
          options."com.sun:auto-snapshot" = "false";
        };
        "log" = {
          type = "zfs_fs";
          mountpoint = "/var/log";
          options."com.sun:auto-snapshot" = "false";
        };
        "tmp" = {
          type = "zfs_fs";
          mountpoint = "/tmp";
          options."com.sun:auto-snapshot" = "false";
        };
      };
    };
  };
}
