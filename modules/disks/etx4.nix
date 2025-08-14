{ lib, config, sources, ...}:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.disk;
in {
  config = mkIf (cfg.enable && cfg.rootFs == "ext4") {
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
        type = "filesystem";
        format = "ext4";
        mountpoint = "/";
      };
      nixfsContent = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/nix";
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
          rootfs = mkIf (!cfg.impermanence.enable) {
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
          nix = mkIf cfg.impermanence.enable {
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
              content = nixfsContent;
            } else nixfsContent;
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
