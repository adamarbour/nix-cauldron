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
      feature = {
        printing.enable = true;
        bluetooth = true;
        thunderbolt = true;
        tpm = true;
      };
    };
    secrets.enable = false;
  };
  
  environment.systemPackages = with pkgs; [
    ethtool
    pciutils
  ];
}
