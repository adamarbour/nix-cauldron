{ lib, osConfig, ... }:
let
  inherit (lib) mkDefault;
in {
  config = {
    home.stateVersion = osConfig.system.stateVersion;
    
    # reload system units when changing configs
    systemd.user.startServices = mkDefault "sd-switch";
    
    programs.home-manager.enable = false;
  };
}
