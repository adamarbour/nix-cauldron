{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  config = {
    home.stateVersion = "24.11";
    
    # reload system units when changing configs
    systemd.user.startServices = mkDefault "sd-switch";
    
    programs.home-manager.enable = false;
  };
}
