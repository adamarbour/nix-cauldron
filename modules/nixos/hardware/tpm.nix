{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkEnableOption;
  
  cfg = config.cauldron.host.tpm;
in {
  options.cauldron.host.tpm = {
    enable = mkEnableOption "Should the device load tpm drivers and support.";
  };
  
  config = mkIf cfg.enable {
    security.tpm2 = {
      enable = mkDefault true;
      abrmd.enable = mkDefault false;
      tctiEnvironment.enable = mkDefault true;
      pkcs11.enable = mkDefault true;
    };
    boot.initrd.kernelModules = [ "tpm" ];
  };
}
