{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  persistRoot = if config.cauldron.impermanence.enable then "/persist/system" else ""; 
  secretsRepo = sources.secrets;
  
  cfg = config.cauldron.secrets;
in {
  imports = [
    (sources.sops-nix + "/modules/sops")
  ];
  options.cauldron.secrets = {
    enable = mkEnableOption "Enable secrets ... shhhh";
  };
  
  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = "${secretsRepo}/secrets/crown.yaml";
      age = {
      	sshKeyPaths = [ "${persistRoot}/etc/ssh/ssh_host_ed25519_key" ];
      	keyFile = "${persistRoot}/var/lib/sops-nix/key.txt";
      	generateKey = true;
      };
      secrets = {
        user_passwd = {};
      };
    };
    environment.systemPackages = with pkgs; [
    	age
    	ssh-to-age
    ];
  };
}
