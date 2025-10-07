{ ... }:
let
  uplink = "enp1s0";
  mtuMin = 1504;
  mtuMax = 9000;
in {
  networking.interfaces.enp7s0.useDHCP = true; # DHCP the onboard NIX (we only use it for setup)
  systemd.network.links."00-${uplink}" = {
    matchConfig = { MACAddressPolicy = "persistent"; };
    linkConfig = { Name = uplink; MTUBytes = mtuMax; };
  };
  
  systemd.network.networks."10-${uplink}" = {
    matchConfig.Name = uplink;
    networkConfig = { LinkLocalAddressing = "no"; };
    vlan = [ "${uplink}.10" "${uplink}.20" "${uplink}.30" "${uplink}.40" ];
  };
  
  systemd.network.netdevs = {
    # Management
    "${uplink}.10" = { netdevConfig = { Kind = "vlan"; Name = "${uplink}.10"; MTUBytes = mtuMin; }; vlanConfig.Id = 10; };
    # Comms
    "${uplink}.20" = { netdevConfig = { Kind = "vlan"; Name = "${uplink}.20"; MTUBytes = mtuMin; }; vlanConfig.Id = 20; };
    # Storage
    "${uplink}.30" = { netdevConfig = { Kind = "vlan"; Name = "${uplink}.30"; MTUBytes = mtuMax; }; vlanConfig.Id = 30; };
    # IoT
    "${uplink}.40" = { netdevConfig = { Kind = "vlan"; Name = "${uplink}.40"; MTUBytes = mtuMin; }; vlanConfig.Id = 40; };
    # Bridge
    "br40" = {
      vlanConfig.Id = 40;
      netdevConfig = { Kind = "bridge"; Name = "br40"; MTUBytes = mtuMin; };
      bridgeConfig = { VLANFiltering = true; STP = true; };
    };
  };
  systemd.network.networks = {
    "20-${uplink}.10" = {
      matchConfig.Name = "${uplink}.10";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.31.10.7/24"; } ];
      routes = [ { Destination = "0.0.0.0/0"; Gateway = "172.31.10.254"; Metric = 100; } ];
    };
    "20-${uplink}.20" = {
      matchConfig.Name = "${uplink}.20";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.31.20.7/24"; } ];
    };
    "20-${uplink}.30" = {
      matchConfig.Name = "${uplink}.30";
      networkConfig.DHCP = "no";
      addresses = [ { Address = "172.31.30.7/24"; } ];
    };
    "21-${uplink}.40" = {
      matchConfig.Name = "${uplink}.40";
      networkConfig.Bridge = "br40";
      bridgeVLANs = [ { VLAN = 40; } ];
    };
    "22-br40" = {
      matchConfig.Name = "br40";
      networkConfig.DHCP = "ipv4";
      dhcpV4Config.UseRoutes = false;
      bridgeVLANs = [ { VLAN = 40; } ];
    };
  };
}
