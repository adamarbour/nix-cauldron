{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  profileList = [
    "desktop"
    "laptop"
    "server"
    "container"
    "graphical"
    "gaming"
    "workstation"
    "hypervisor"
  ];
in {
  options.cauldron = {
    profiles = mkOption {
      type = types.listOf (types.enum profileList);
      default = [];
      description = "List of profiles enabled for this host";
      example = [ "graphical" "workstation" ];
    };
  };
}
