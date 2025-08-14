{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault;
in {
  config = mkMerge [
    {
      users.users.root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYiOynu6CwX4zHlSNxc0H4MkpseEhoGCOL6ls+laxdc aarbour"
        ];
      };
    }
    
    # Secrets
    (mkIf config.cauldron.secrets.enable {
      users.users.root.hashedPasswordFile = config.sops.secrets.passwd.path;
    })
    
    # No Secrets
    (mkIf (!config.cauldron.secrets.enable) {
      users.users.root.initialPassword = ".";
    })
  ];
}
