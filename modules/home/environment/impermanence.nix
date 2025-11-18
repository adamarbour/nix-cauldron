{ lib, config, osConfig, sources, ... }:
let
  inherit (lib) mkIf;
  
  impermanence = osConfig.cauldron.host.disk.impermanence;
  cfg = osConfig.cauldron.host.impermanence;
in {
  imports = [ (sources.impermanence + "/home-manager.nix") ];
  
  config = mkIf impermanence.enable {
    home.persistence."${cfg.root}${config.home.homeDirectory}" = {
      directories = [];
      files = [];
      allowOther = true;
    };
  };
}
