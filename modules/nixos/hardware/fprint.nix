{ lib, pkgs, config, ...}:
let
  inherit (lib) types mkIf mkEnableOption mkOption genAttrs;
  cfg = config.cauldron.host.feature.fprint;
in {
  options.cauldron.host.feature.fprint = {
    enable = mkEnableOption "Wether to enable fingerprint reader support";
    pamServices = mkOption {
      type = types.listOf types.str;
      default = [ "login" "sudo" "greetd" "tuigreet" ];
      example = [ "login" "sudo" "su" "swaylock" ];
      description = "PAM services to enable fprintAuth on.";
    }; 
  };
  
  config = mkIf cfg.enable {
    services.fprintd.enable = true;
    # Toggle fingerprint auth per selected PAM service
    security.pam.services = genAttrs cfg.pamServices (_: { fprintAuth = true; });
  };
}
