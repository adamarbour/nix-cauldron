{ ... }:
{
  fileSystems."/persist".neededForBoot = true;
  disko.devices.disk.disk1 = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        data = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" "-L DATA" ];
            mountOptions = [ "compress=zstd" "lazytime" ];
            subvolumes = {
              "/home" = {
                mountpoint = "/home";
              };
              "/persist" = {
                mountpoint = "/persist";
              };
            };
          };
        };
      };
    };
  };
}
