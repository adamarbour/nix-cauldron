{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.cauldron.services.lightdm;
in {

  options.cauldron.services.lightdm = {
    enable =  mkEnableOption "LightDM";
  };

  config = mkIf cfg.enable {
    services.xserver.displayManager.lightdm = {
      enable = true;
    };
  };
}