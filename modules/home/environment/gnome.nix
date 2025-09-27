{ osConfig, ... }:
{
  services.gnome-keyring.enable = osConfig.services.gnome.gnome-keyring.enable;
}
