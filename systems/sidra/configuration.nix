{ pkgs, ... }:
{ 
  cauldron = {
    profiles = [
      "server"
      "kvm"
    ];
    
    host = {
      boot = {
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
    };
    services = {
      cloud-init= {
        enable = true;
        dataSources = [ "Oracle" ];
      };
      innernet = {
        server.arbour-cloud = {
          enable = true;
          settings = {
            openFirewall = true;
            cidr = "172.31.0.0/16";
            listenPort = 51820;
            privateKeyFile = "/run/secrets/wg-key";
            publicKey = "jJZSbRd/g4hKLSoNkyT0p+kFNVJOA/UTaAXS4ikmT3s=";
            externalEndpoint = "40.233.13.66:51820";
            cidrs = {
              home = { cidr = "172.31.1.0/24"; parent = "arbour-cloud"; };
              prynthian = { cidr = "172.31.7.0/24"; parent = "arbour-cloud"; };
            };
            peers = {
              cassian = { ip = "172.31.1.213"; cidr = "home"; publicKey = "/wYcBIwBvnPbVJqSN7o/EJIazS6lc9KaVnzjtl6Vc3s="; isAdmin = true; };
            };
          };
        };
      };
    };
    secrets = {
      enable = true;
      items = {
        "wg-key" = {
          sopsFile = "trove/wg/sidra.key";
          format = "binary";
        };
      };
    };
  };
}
