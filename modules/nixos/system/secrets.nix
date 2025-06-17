{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  persistRoot = if config.cauldron.impermanence.enable then "/persist/system" else "";
  persistHome = if config.cauldron.impermanence.enable then "/persist/users" else ""; 
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
      };
      secrets = {
        user_passwd.neededForUsers = true;
        "user/ssh_key" = {
          key = "id_ed25519";
          owner = "aarbour";
          mode = "0600";
          path = "${persistHome}/home/aarbour/.ssh/id_ed25519";
        };
        "user/ssh_pub" = {
          key = "id_ed25519_pub";
          owner = "aarbour";
          mode = "0644";
          path = "${persistHome}/home/aarbour/.ssh/id_ed25519.pub";
        };
      };
    };
    environment.systemPackages = with pkgs; [
    	age
    	ssh-to-age
    ];
  };
}
