{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault mkMerge;
in {
  config = mkMerge [
    (mkIf config.cauldron.impermanence.enable {
      systemd.tmpfiles.rules = [
        "d /persist/users/home/aarbour 0700 aarbour users -"
      ];
    })
    
#    (mkIf config.cauldron.secrets.enable {
#      users.users.aarbour.hashedPasswordFile = config.sops.secrets.user_passwd.path;
#    })
    
#    (mkIf (!config.cauldron.secrets.enable) {
#      users.users.aarbour.initialPassword = "nixos";
#    })
    
    {
      users.users.aarbour = {
        initialPassword = "nixos";
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
          # TODO: Fix...
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAc2MLBtYJd5b95ezUrHuZoENM50ETU8Un21lQa01eCq"
        ];
      };
    }
  ];
}
