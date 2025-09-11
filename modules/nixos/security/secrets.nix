{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  impermanence = config.cauldron.host.disk.impermanence;
  persistRoot = if (impermanence.enable) then config.cauldron.host.impermanence.root else "";
  
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
