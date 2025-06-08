{ lib, config, ... }:
{
  systemd.network.enable = config.networking.useNetworkd;
  # wired networks
  systemd.network.networks.wired = {
    matchConfig = {
      Name = "en*";
    };
    networkConfig = {
      DHCP = "ipv4";
      DNSDefaultRoute = false;
    };
    dhcpV4Config = {
      RouteMetric = 100;
    };
  };
  # wireless networks
  systemd.network.networks.wireless = {
    matchConfig = {
      Type = "wlan";
    };
    networkConfig = {
      DHCP = "ipv4";
      DNSDefaultRoute = false;
    };
    dhcpV4Config = {
      RouteMetric = 600;
    };
  };
}
