{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.cauldron.host.boot.plymouth;
in {
  options.cauldron.host.boot.plymouth = {
    enable = mkEnableOption "Use plymouth";
  };

  config = mkIf cfg.enable {
    boot.plymouth = {
      enable = true;
    };
  };
}