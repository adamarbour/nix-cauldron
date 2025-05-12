{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.networking;
in {
  
  config = {
    systemd.network = {
      enable = true;
      networks."70-wired" = {
        matchConfig.Name = "en*";
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
        };
        dhcpV4Config = {
          RouteMetric = 100;
        };
      };
      networks."80-wireless" = {
        matchConfig.Type = "wlan";
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
        };
        dhcpV4Config = {
          RouteMetric = 600;
        };
      };
    };
    networking = {
      dhcpcd.enable = false;
    };
  };
}