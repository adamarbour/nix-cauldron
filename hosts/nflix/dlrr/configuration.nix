{ pkgs, ... }:
{
  cauldron = {
    profiles = [
      "server"
      "kvm"
    ];
    host = {
      boot = {
        kernel = pkgs.linuxPackages;
        loader = "systemd";
      };
      hardware.cpu = "intel";
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/vda";
        impermanence = {
          enable = true;
          rootSize = "1G";
        };
        swap.enable = true;
      };
      network = {
        wireguard.tunnels = {
          "nflix" = {
            addresses = [ "10.11.12.13/24" ];
            privateKey = { kind = "sops"; path = "wg/dlrr.key"; };
            listenPort = 51820;
            openFirewall = true;
            enableIPForward = true;
          };
        };
      };
    };
    services = {
      cloud-init = {
        enable = true;
        dataSources = [ "NoCloud" ];
      };
    };
    secrets.enable = true;
  };
}
