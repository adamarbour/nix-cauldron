{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in {
  services = mkIf (!(lib.elem "container" profiles)) {
    timesyncd.enable = mkDefault true;
    chrony.enable = mkDefault false;
  };
}
