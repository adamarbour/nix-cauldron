{ pkgs, config, ... }:
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
  
  # Helpful for high-throughput storage...
  boot.kernel.sysctl = {
    "net.core.netdev_max_backlog" = 250000;
    "net.core.rmem_max" = 268435456;
    "net.core.wmem_max" = 268435456;
    "net.ipv4.tcp_rmem" = "4096 87380 268435456";
    "net.ipv4.tcp_wmem" = "4096 655536 268435456";
  };
  
  environment.systemPackages = with pkgs; [
    pciutils
  ];
}
