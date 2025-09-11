{
  cauldron.registry.wireguard = {
    tunnels = {
      "arbour-cloud" = {
        cassian = {
          peerName = "cassian";
          publicKey = "/wYcBIwBvnPbVJqSN7o/EJIazS6lc9KaVnzjtl6Vc3s=";
          addresses = "172.31.7.11/24";
        };
      };
    };
    defaults = {
      "wg-cloud" = { mtu = 1380; };
    };
  };
}
