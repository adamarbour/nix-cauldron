{
  systemd = {
    # allow the system to boot without the network interfaces online
    network.wait-online.enable = false;
    services = {
      NetworkManager-wait-online.enable = false;
      # prevent failures from services that are restarted instead of stopped
      systemd-networkd.stopIfChanged = false;
      systemd-resolved.stopIfChanged = false;
    };
  };
}
