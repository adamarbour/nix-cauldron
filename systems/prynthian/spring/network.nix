{ ... }:
{
  systemd.network.networks = {
    "10-mgmt" = {
      matchConfig.MACAddress = "e8:6a:64:eb:3c:df";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.24.1/24"; } ];
      dns = [ "172.16.24.254" "9.9.9.9" ];
      routes = [ { Gateway = "172.16.24.254"; } ];
      linkConfig.RequiredForOnline = "routable";
    };
    "20-fabric" = {
      matchConfig.MACAddress = "98:03:9b:dc:69:f1";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.13.1/24"; } ];
      linkConfig.RequiredForOnline = "no";
    };
  };
}
