{ lib, osConfig, ... }:
let
  inherit (lib) mkOption types;
in {
  options.cauldron = {
    profiles = mkOption {
      type = types.listOf types.str;
      default = osConfig.cauldron.profiles;
      readOnly = true;
      description = "Profiles inherited from the system.";
    };
  };
}
