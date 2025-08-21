{ ... }:
{
  systemd.network.networks = {
    "10-mgmt" = {
      matchConfig.MACAddress = "f8:75:a4:18:bd:3f";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.24.3/24"; } ];
      dns = [ "172.16.24.254" "9.9.9.9" ];
      routes = [ { Gateway = "172.16.24.254"; } ];
      linkConfig.RequiredForOnline = "routable";
    };
    "20-fabric" = {
      matchConfig.MACAddress = "98:03:9b:e0:45:01";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.13.3/24"; } ];
      linkConfig.RequiredForOnline = "no";
    };
  };
}
