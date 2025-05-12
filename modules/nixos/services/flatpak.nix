{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkDefault;

  cfg = config.cauldron.services.flatpak;
in {
  
  options.cauldron.services.flatpak = {
  };

  config = {
    services.flatpak = {
      enable = true;
      update = {
        onActivation = true;
        auto = {
          enable = true;
          onCalendar = "weekly";
        };
      };
      packages = [
        "com.github.tchx84.Flatseal"
      ];
    };
  };
}