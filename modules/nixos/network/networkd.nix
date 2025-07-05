{ lib, config, ... }:
{
  systemd.network.enable = config.networking.useNetworkd;
}
