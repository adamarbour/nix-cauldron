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
            publicKey = "jJZSbRd/g4hKLSoNkyT0p+kFNVJOA/UTaAXS4ikmT3s=";
            privateKey = { kind = "sops"; path = "wg/sidra.key"; };
            endpoint = "wg1.arbour.cloud";
            listenPort = 51820;
            addresses = [ "172.31.7.254/32" "2001:db8:ac::254/128" ];
            openFirewall = true;
            enableIPForward = true;
            extraAllowedIPs = [ "172.31.7.0/24" "2001:db8:ac::/26" ];
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
