{ pkgs, ... }:
{
  cauldron = {
    profiles = [
      "server"
    ];
    host = {
      boot = {
        kernel = pkgs.linuxPackages;
        loader = "systemd";
      };
      hardware.cpu = "intel";
      network = {
        tailscale.enable = true;
      };
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/nvme0n1";
        impermanence = {
          enable = true;
          rootSize = "2G";
        };
      };
    };
    secrets.enable = false;
  };
}
