{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.services.redshift;
in {

  config = {
    services.redshift = {
      enable = true;
    };
    location.latitude = 29.7;
    location.longitude = -95.4;
  };
}