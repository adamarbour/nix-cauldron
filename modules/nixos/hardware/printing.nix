{ lib, pkgs, config, ...}:
let
  inherit (lib) types mkIf mkDefault mkOption mkEnableOption attrValues;
  cfg = config.cauldron.host.feature.printing;
in {
  options.cauldron.host.feature.printing = {
    enable = mkEnableOption "Wether to enable printing support";
    
    extraDrivers = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "A list of additional drivers to install for printing";
    };
  };
  
  config = mkIf cfg.enable {
    # enable cups and some drivers for common printers
    services = {
      printing = {
        enable = true;
        webInterface = config.services.printing.enable;
        browsing = mkDefault true;
        allowFrom = [ "localhost" ];
        drivers = attrValues (
          {
            inherit (pkgs) gutenprint cnijfilter2;
          } // cfg.extraDrivers
        );
      };
      
      # required for network discovery of printers
      avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
        openFirewall = true;
      };
    };
  };
}
