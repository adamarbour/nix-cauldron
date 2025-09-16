{ lib, pkgs, config, ... }:
let
  inherit (lib) elem mkIf mkMerge mkDefault;
  enableUser = (elem "aarbour" config.cauldron.host.users);
in {
  config = mkMerge [
    (mkIf enableUser {
      users.users.aarbour = {
        description = "Adam Arbour";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYiOynu6CwX4zHlSNxc0H4MkpseEhoGCOL6ls+laxdc aarbour"
        ];
      };
    })
    
    # Impermanence
    (mkIf (enableUser && config.cauldron.host.disk.impermanence.enable) {
      # TODO: Fix this ...
    })
    
    # Secrets
    (mkIf (enableUser && config.cauldron.secrets.enable) {
      users.users.aarbour.hashedPasswordFile = config.sops.secrets.passwd.path;
    })
  ];
}
