# DESC: Device options that are used to configure a per device setup
# contains things like hardware, disk layout, impermanence and networking
# TODO: Fix me for mdbook
{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  
  cfg = config.cauldron.device;
in {
  options.cauldron.device = {
    # TODO: Move the relevant cauldron.host.<> options here and reconfigure devices
  };
  
  config = {
    
  };
}
