{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  profileList = [
    "server"
    "laptop"
    "desktop"
    "container"
    "graphical"
    "gaming"
    "workstation"
    "hypervisor"
    "kvm"
    "remote-builder"
  ];
  
  cfg = config.cauldron;
  coreProfiles = [ "server" "laptop" "desktop" ];
  coreSelected = builtins.filter (p: builtins.elem p coreProfiles) cfg.profiles;
  coreCount = builtins.length coreSelected;
in {
  options.cauldron = {
    profiles = mkOption {
      type = types.listOf (types.enum profileList);
      default = [];
      description = "List of profiles enabled for this host";
      example = [ "graphical" "workstation" ];
    };
  };
  config = {
    assertions = [
      { assertion = coreCount == 1;
        message = ''
          cauldron.profiles must contain exactly one of: ${lib.concatStringsSep ", " coreProfiles}.
          Current: ${lib.concatStringsSep ", " cfg.profiles}
        '';
      }
    ];
  };
}
