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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6RrWcDLtFsoVWp5SmipGZX1YaqfXK6vus1rZteqCcA aarbour"
        ];
      };
    }
  ];
}
