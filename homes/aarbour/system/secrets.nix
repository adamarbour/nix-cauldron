{ lib, config, osConfig, ... }:
let
  inherit (lib) mkIf;
  cfg = osConfig.cauldron.secrets;
in {
  sops.secrets = mkIf cfg.enable {
    age_key = {
      path = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
  };
}
