{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  persistRoot = ""; # TODO: Fix with impermanence
  persistHome = ""; # TODO: Fix with impermanence
  secretsRepo = sources.secrets;
  cfg = config.cauldron.secrets;
in {
  imports = [ (sources.sops-nix + "/modules/sops") ];
  
  options.cauldron.secrets = {
    enable = mkEnableOption "Enable secrets ... shhhh";
  };
  
  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = "${secretsRepo}/trove/default.yaml";
      age = {
        	sshKeyPaths = [ "${persistRoot}/etc/ssh/ssh_host_ed25519_key" ];
      };
    };
    
    environment.systemPackages = with pkgs; [
      	age
      	sops
      	ssh-to-age
    ];
  };
}
