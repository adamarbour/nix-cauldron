{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault;
in {
  config = mkMerge [
    # Secrets
    (mkIf config.cauldron.secrets.enable {
      sops.secrets."passwd" = {};
      sops.secrets."id_ed25519.pub" = {};
      users.users.root = {
        hashedPasswordFile = config.sops.secrets."passwd".path;
        openssh.authorizedKeys.keys = [
          (builtins.readFile config.sops.secrets."id_ed25519.pub".path)
        ];
      };
    })
    
    # No Secrets
    (mkIf (!config.cauldron.secrets.enable) {
      users.users.root = {
        initialPassword = ".";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYiOynu6CwX4zHlSNxc0H4MkpseEhoGCOL6ls+laxdc aarbour"
        ];
      };
    })
  ];
}
