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
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/sda";
        impermanence = {
          enable = true;
          rootSize = "1G";
        };
        swap.enable = true;
      };
      network = {
        wireguard.tunnels = {
          "arbour-cloud" = {
            addresses = [ "172.31.7.1/24" ];
            privateKey = { kind = "sops"; path = "wg/sidra.key"; };
            listenPort = 51820;
            openFirewall = true;
            enableIPForward = true;
          };
        };
      };
    };
    services = {
      cloud-init= {
        enable = true;
        dataSources = [ "Oracle" ];
      };
    };
    secrets.enable = true;
  };
}
