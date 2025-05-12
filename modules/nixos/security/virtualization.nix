{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.security;
in {
  config = {
    # flush the L1 data cache before entering guests
    security.virtualisation.flushL1DataCache = "always";
  };
}