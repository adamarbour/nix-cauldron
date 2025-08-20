{ lib, config, sources, ...}:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.disk;
in {
  config = mkIf (cfg.enable && cfg.rootFs == "btrfs") {
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
        type = "btrfs";
        extraArgs = [ "-f" "-L BTRFS" ];
        mountOptions = [ "compress=zstd" "noatime" ];
        subvolumes = {
          "/" = mkIf (!cfg.impermanence.enable) {
            mountpoint = "/";
          };
          "/nix" = {
            mountpoint = "/nix";
            mountOptions = [ "compress-force=zstd:3" ];
          };
          "/persist" = mkIf (cfg.impermanence.enable) {
            mountpoint = "/persist";
            mountOptions = [ "lazytime" ];
          };
          "/snapshots" = {
            mountpoint = "/.snapshots";
          };
          "/log" = {
            mountpoint = "/var/log";
          };
          "/tmp" = {
            mountpoint = "/tmp";
          };
        };
      };
      nixfsContent = {
        type = "btrfs";
        extraArgs = [ "-f" "-L BTRFS" ];
        mountOptions = [ "compress=zstd" "noatime" ];
        subvolumes = {
          "/nix" = {
            mountpoint = "/nix";
            mountOptions = [ "compress-force=zstd:3" ];
          };
          "/persist" = {
            mountpoint = "/persist";
            mountOptions = [ "lazytime" ];
          };
          "/snapshots" = {
            mountpoint = "/.snapshots";
          };
          "/log" = {
            mountpoint = "/var/log";
          };
          "/tmp" = {
            mountpoint = "/tmp";
          };
        };
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
            size = "512M";
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
  };
}
