{ lib, pkgs, ... }:
{
  systemd.network.networks."10-eth0" = {
    matchConfig = {
      MACAddress = "00:f1:70:f4:e5:63";
    };
    addresses = [
      { Address = "23.95.134.145/24"; }
      { Address = "2605:8340:3:201::a/64"; }
    ];
    routes = [
      { routeConfig = { Gateway = "23.95.134.1"; }; }
      { routeConfig = { Gateway = "2605:8340:3::1"; }; }
    ];
    networkConfig = {
      DNS = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
    };
  };
}
