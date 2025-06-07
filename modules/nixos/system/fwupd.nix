{ config, ... }:
{
  services.fwupd = {
    enable = true;
    daemonSettings.EspLocation = config.boot.loader.efi.efiSysMountPoint;
  };
}
