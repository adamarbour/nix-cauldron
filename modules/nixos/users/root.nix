{ lib, config, ... }:
let
  inherit (lib) mkIf mkMerge;
in {
  config = mkMerge [
    (mkIf config.cauldron.secrets.enable {
      users.users.root.hashedPasswordFile = config.sops.secrets.user_passwd.path;
    })
    
    (mkIf (!config.cauldron.secrets.enable) {
      users.users.root.initialPassword = "Ch4ang3Me";
    })
    
    {
      users.users.root = {
        openssh.authorizedKeys.keys = [
          # TODO: Fix...
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAc2MLBtYJd5b95ezUrHuZoENM50ETU8Un21lQa01eCq"
        ];
      };
    }
  ];
}
