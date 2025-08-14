{ lib, config, ...}:
let
  inherit (lib) types mkIf mkDefault mkOption;
  cfg = config.cauldron.host.feature;
in {
  options.cauldron.host.feature.tpm = mkOption {
    type = types.bool;
    default = false;
    description = "Wether to enable tpm support";
  };
  
  config = mkIf cfg.tpm {
    security.tpm2 = {
      enable = mkDefault true;
      abrmd.enable = mkDefault false;
      tctiEnvironment.enable = mkDefault true;
      pkcs11.enable = mkDefault true;
    };
    boot.initrd.kernelModules = [ "tpm" ];
  };
}
