{
  device ? throw "Pls specify primary device...",
  ...
}:
{
  disko.devices = {
    disk = {
      disko0 = {
        type = "disk";
        inherit device;
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            btrfs = {
            	size = "100%";
            	content = {
            	  type = "btrfs";
                extraArgs = [ "-f" "-L BTRFS" ];
                mountOptions = [ "compress=zstd" "noatime" ];
                subvolumes = {
                  "/rootfs" = {
                    mountpoint = "/";
                  };
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
            };
          };
        };
      };
    };
  };
}
