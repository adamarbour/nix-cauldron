{ lib, config, ... }:
{
  # TODO: if graphical profile is enabled
  config = {
    services.pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa.enable = true;
    };
    systemd.user.services = {
      pipewire.wantedBy = [ "default.target" ];
      pipewire-pulse.wantedBy = [ "default.target" ];
    };
  };
}
