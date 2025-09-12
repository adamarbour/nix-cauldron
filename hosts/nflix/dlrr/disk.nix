{
  disko.devices.disk.disk1 = {
    device = "/dev/vdb";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        data = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/media" = {
                mountOptions = [ "compress=zstd" ];
                mountpoint = "/srv/media";
              };
              "/cache" = {
                mountpoint = "/srv/cache";
              };
            };
          };
        };
      };
    };
  };
}
