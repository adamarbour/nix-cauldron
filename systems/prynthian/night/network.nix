{ ... }:
{
  systemd.network.networks = {
    "10-mgmt" = {
      matchConfig.MACAddress = "04:d9:f5:83:56:42";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.24.7/24"; } ];
      dns = [ "172.16.24.254" "9.9.9.9" ];
      routes = [ { Gateway = "172.16.24.254"; } ];
      linkConfig.RequiredForOnline = "routable";
    };
    "20-fabric" = {
      matchConfig.MACAddress = "24:be:05:81:f1:00";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.16.13.7/24"; } ];
      linkConfig.RequiredForOnline = "no";
    };
  };
}
