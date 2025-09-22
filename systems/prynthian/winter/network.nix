{ ... }:
{
  systemd.network.networks = {
    "10-mgmt" = {
      matchConfig.MACAddress = "e8:6a:64:f2:70:59";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.24.4/24"; } ];
      dns = [ "172.16.24.254" "9.9.9.9" ];
      routes = [ { Gateway = "172.16.24.254"; } ];
      linkConfig.RequiredForOnline = "routable";
    };
    "20-fabric" = {
      matchConfig.MACAddress = "98:03:9b:dc:99:91";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.13.4/24"; } ];
      linkConfig.RequiredForOnline = "no";
    };
  };
}
