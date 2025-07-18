{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault mkMerge mkEnableOption;
  cfg = config.cauldron.home-manager;
in {
  options.cauldron.home-manager = {
    enable = mkEnableOption "Enable home-manager as a module";
  };
  
  config = mkMerge [
    (mkIf config.cauldron.impermanence.enable {
      systemd.tmpfiles.rules = [
        "d /persist/users/home/aarbour 0700 aarbour users -"
      ];
    })
    
    (mkIf config.cauldron.secrets.enable {
      users.users.aarbour.hashedPasswordFile = config.sops.secrets.user_passwd.path;
    })
    
    (mkIf (!config.cauldron.secrets.enable) {
      users.users.aarbour.initialPassword = "nixos";
    })
    
    # Enable home-manager
    (mkIf (cfg.enable) {
      home-manager.users.aarbour = { ... }: {
        imports = [ 
          ../../home-manager
        ];
        programs.git = {
          userName = "Adam Arbour";
          userEmail = "845679+adamarbour@users.noreply.github.com";
        };
      };
    })
    
    {
      users.users.aarbour = {
        uid = mkDefault 1000;
        isNormalUser = true;
        home = "/home/aarbour";
        description = "Adam Arbour";
        
        extraGroups = [
          "wheel"
          "nix"
          "audio"
          "video"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6RrWcDLtFsoVWp5SmipGZX1YaqfXK6vus1rZteqCcA aarbour"
        ];
      };
    }
  ];
}
