{ ... }:
{
  systemd.network.networks = {
    "10-mgmt" = {
      matchConfig.MACAddress = "e8:6a:64:eb:32:27";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.24.2/24"; } ];
      dns = [ "172.16.24.254" "9.9.9.9" ];
      routes = [ { Gateway = "172.16.24.254"; } ];
      linkConfig.RequiredForOnline = "routable";
    };
    "20-fabric" = {
      matchConfig.MACAddress = "00:10:e0:d2:b0:19";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.13.2/24"; } ];
      linkConfig.RequiredForOnline = "no";
    };
  };
}
