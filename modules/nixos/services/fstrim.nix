{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkDefault;

  cfg = config.cauldron.services.fstrim;
in {
  
  options.cauldron.services.fstrim = {
  };

  config = {
    services.fstrim.enable = mkDefault true;
  };
}