{ lib, config, ...}:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "graphical" profiles) {
    services.pulseaudio.enable = !config.services.pipewire.enable;
  };
}
