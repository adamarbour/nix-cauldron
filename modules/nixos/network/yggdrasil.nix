{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption mkForce;
  inherit (lib.types) bool listOf str;
  
  cfg = config.cauldron.network.yggdrasil;
in {
  options.cauldron.network.yggdrasil = {
    enable = mkEnableOption "Enable yggdrasil networking";
    
    isPeer = mkOption {
      type = bool;
      default = false;
      example = true;
      description = ''
        Whether the target host should operate as Yggdrasil Peer.
      '';
    };
  };
  
  config = mkIf cfg.enable {
    services.yggdrasil = {
      enable = true;
      persistentKeys = true;
      openMulticastPort = true;
    };
  };
}
