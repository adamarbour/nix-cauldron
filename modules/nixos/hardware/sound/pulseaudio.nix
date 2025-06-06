{ lib, config, ... }:
{
  # TODO: if graphical profile is enabled
  config = {
    # pulseaudio backup
    services.pulseaudio.enable = !config.services.pipewire.enable;
  };
}
