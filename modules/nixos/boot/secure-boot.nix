{ lib, pkgs, config, sources, ...}:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.options) mkEnableOption;
  cfg = config.cauldron.host.boot;
in {
  imports = [
    ((import sources.lanzaboote).nixosModules.lanzaboote)
  ];
  
  options.cauldron.host.boot.secureBoot = mkEnableOption ''
    Switch on secure-boot and load the necessary packages.
  '';
  config = mkIf cfg.secureBoot {
    environment.systemPackages = [
      pkgs.sbctl
    ];
    
    boot.loader.systemd-boot.enable = mkForce false;
    
    boot = {
      bootspec.enable = true;
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
  };
}
