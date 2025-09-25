# DESC: System specific options for each host ... features, secrets, packages, kernel, security
# these are things that are very much a software level. So bluetooth might be enabled as hardware BUT
# bluetooth service might be disabled.
# TODO: Fix me for mdbook
{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  
  cfg = config.cauldron.system;
in {
  options.cauldron.system = {
    
  };
  config = {
    
  };
}
