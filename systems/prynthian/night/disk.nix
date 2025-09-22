{ ... }:
let
  nasDiskDefaults = {
    type = "disk";
    content = {
      type = "gpt";
      partitions.zfs = {
        size = "100%";
        content = {
          type = "zfs";
          pool = "nas-pool";
        };
      };
    };
  };
  specialDiskDefaults = {
    type = "disk";
    content = {
      type = "gpt";
      partitions.zfs = {
        size = "250G";
        content = {
          type = "zfs";
          pool = "nas-pool";
        };
      };
      partitions.empty = {
        size = "100%"; # Used for other purposes
      };
    };
  };
in {
  disko.devices.disk.hdd1 = {
    device = "/dev/disk/by-id/ata-ST16000NM001G-2KK103_ZL28QLQT";
  } // nasDiskDefaults;
  disko.devices.disk.hdd2 = {
    device = "/dev/disk/by-id/ata-ST16000NM000J-2TW103_ZR5G0RM5";
  } // nasDiskDefaults;
  disko.devices.disk.hdd3 = {
    device = "/dev/disk/by-id/ata-ST16000NM001G-2KK103_ZL20T8V6";
  } // nasDiskDefaults;
  disko.devices.disk.special1 = {
    device = "/dev/disk/by-id/ata-CT1000MX500SSD1_2306E6AB159A";
  } // specialDiskDefaults;
  disko.devices.disk.special2 = {
    device = "/dev/disk/by-id/ata-SPCC_M.2_SSD_GDFCPBAS5JZKN8VXNNOD";
  } // specialDiskDefaults;

  # NAS-POOL
  disko.devices.zpool."nas-pool" = {
    type = "zpool";
    options = {
      cachefile = "none";
      ashift = "12";
      autotrim = "off";
    };
    rootFsOptions = {
      acltype = "posixacl";
      compression = "zstd";
      atime = "off";
      xattr = "sa";
      mountpoint = "none";
      dnodesize = "auto";
      logbias = "throughput";
      "com.sun:auto-snapshot" = "false";
      refreservation = "1G";
    };
    mode.topology = {
      type = "topology";
      # storage
      vdev = [
        { mode = "raidz1";
          members = [
            "hdd1"
            "hdd2"
            "hdd3"
          ];
        }
      ];
      # metadata
      special = [
        { mode = "mirror";
          members = [
            "special1"
            "special2"
          ];
        }
      ];
    };
    datasets = {
      "media/library" = {
        type = "zfs_fs";
        mountpoint = "/srv/nas/media";
        options = {
          compression = "off";
          recordsize = "1M";
        };
      };
      "media/photos" = {
        type = "zfs_fs";
        mountpoint = "/srv/nas/media/photos";
        options = {
          compression = "off";
          recordsize = "1M";
        };
      };
      "net/backups" = {
        type = "zfs_fs";
        mountpoint = "/srv/nas/backups";
        options = {
          recordsize = "1M";
        };
      };
      "net/shares" = {
        type = "zfs_fs";
        mountpoint = "/srv/nas/shares";
      };
      "local/files" = {
        type = "zfs_fs";
        mountpoint = "/srv/nas/files";
        options = {
          recordsize = "16K";
        };
      };
    };
  };
}
