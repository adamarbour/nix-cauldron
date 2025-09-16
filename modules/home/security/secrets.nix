{ lib, name, config, sources, osConfig, ... }:
let
  inherit (lib) mkIf;
  secretsRepo = sources.secrets;
  cfg = osConfig.cauldron.secrets;
in {
  imports = [ (sources.sops-nix + "/modules/home-manager/sops.nix") ];
  
  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = "${secretsRepo}/trove/${name}.yaml";
      age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };
  };
}
