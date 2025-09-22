{ pkgs, config, ... }:
{
  cauldron = {
    profiles = [
      "server"
    ];
    host = {
      boot = {
        kernel = pkgs.linuxPackages;
        loader = "grub";
        grub.device = "/dev/nvme1n1";
      };
      hardware.cpu = "intel";
      network = {
        tailscale.enable = true;
      };
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/nvme1n1";
        impermanence = {
          enable = true;
          rootSize = "1G";
        };
      };
      feature.mlnx-ofed = true;
    };
    secrets.enable = false;
  };
  
  environment.systemPackages = with pkgs; [
    ethtool
    pciutils
  ];
}
