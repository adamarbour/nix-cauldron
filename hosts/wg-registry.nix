{
  cauldron.registry.wireguard = {
    tunnels = {
      "arbour-cloud" = {
        sidra = {
          publicKey = "jJZSbRd/g4hKLSoNkyT0p+kFNVJOA/UTaAXS4ikmT3s=";
          addresses = [ "172.31.7.1/24" "2001:db8:ac::1/64" ];
          endpoint = "40.233.13.66";
          listenPort = 51820;
        };
        cassian = {
          publicKey = "/wYcBIwBvnPbVJqSN7o/EJIazS6lc9KaVnzjtl6Vc3s=";
          addresses = [ "172.31.7.11/24" "2001:db8:ac::11/64" ];
          extraAllowedIPs = [ "172.31.7.0/24" "2001:db8:ac::1/64" ];
        };
        morrigan = {
          publicKey = "qBd0mGQuBCxL3Pl401UHTt6Ng1PjbCPRz56vppiwfG8=";
          addresses = [ "172.31.7.13/24" "2001:db8:ac::13/64" ];
          extraAllowedIPs = [ "172.31.7.0/24" "2001:db8:ac::1/64" ];
        };
      };
      "nflix" = {
        dlrr = {
          publicKey = "MRpOWd8l8dCgW3akz2RDUGOw+NBwe81fEXE74mPRglM=";
          addresses = [ "10.11.12.13/24" ];
          endpoint = "23.95.134.145";
          listenPort = 51820;
        };
        cassian = {
          publicKey = "/wYcBIwBvnPbVJqSN7o/EJIazS6lc9KaVnzjtl6Vc3s=";
          addresses = [ "10.11.12.1/24" ];
          extraAllowedIPs = [ "10.11.12.0/24" ];
        };
        morrigan = {
          publicKey = "qBd0mGQuBCxL3Pl401UHTt6Ng1PjbCPRz56vppiwfG8=";
          addresses = [ "10.11.12.2/24" ];
          extraAllowedIPs = [ "10.11.12.0/24" ];
        };
      };
    };
    defaults = {
      "arbour-cloud" = { mtu = 1380; };
    };
  };
}


