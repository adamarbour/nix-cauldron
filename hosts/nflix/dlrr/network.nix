{ lib, pkgs, ... }:
{
  systemd.network.networks."10-eth0" = {
    matchConfig = {
      MACAddress = "00:16:3c:3f:dc:51";
    };
    addresses = [
      { Address = "82.118.230.103/25"; }
      { Address = "2a01:8740:1:ff0b::96ae/64"; }
    ];
    routes = [
      { routeConfig = { Gateway = "82.118.230.1"; }; }
      { routeConfig = { Gateway = "2a01:8740:1:ff00::::1"; }; }
    ];
    networkConfig = {
      DNS = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
    };
  };
}
