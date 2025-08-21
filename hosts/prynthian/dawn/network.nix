{ ... }:
{
  systemd.network.networks = {
    "10-mgmt" = {
      matchConfig.MACAddress = "e8:6a:64:f2:5c:fb";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.24.5/24"; } ];
      dns = [ "172.16.24.254" "9.9.9.9" ];
      routes = [ { Gateway = "172.16.24.254"; } ];
      linkConfig.RequiredForOnline = "routable";
    };
    "20-fabric" = {
      matchConfig.MACAddress = "98:03:9b:e2:04:51";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.13.5/24"; } ];
      linkConfig.RequiredForOnline = "no";
    };
  };
}
