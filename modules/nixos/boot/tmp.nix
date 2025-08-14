{ lib, config, ... }:
let
  inherit (lib) mkDefault mkEnableOption;
  cfg = config.cauldron.host;
in {
  options.cauldron.host = {
    tmpOnTmpfs = mkEnableOption "`/tmp` living on tmpfs. False means it will be cleared manually on each reboot"
      // { default = true; };
  };
  
  config = {
    boot.tmp = {
      useTmpfs = cfg.tmpOnTmpfs;
      tmpfsHugeMemoryPages = mkDefault "within_size";
      cleanOnBoot = mkDefault (!config.boot.tmp.useTmpfs);
    };
  };
}
