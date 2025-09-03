{ ... }:
{
  cauldron.wireguard.tunnels."wg-cloud" = {
    description = "Arbour Cloud";
    peers = [
      {
        name = "cassian";
        publicKey = "/wYcBIwBvnPbVJqSN7o/EJIazS6lc9KaVnzjtl6Vc3s=";
        allowedIPs = [ "172.31.7.3/32" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
