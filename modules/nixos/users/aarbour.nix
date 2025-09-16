{ lib, pkgs, config, ... }:
let
  inherit (lib) elem mkIf mkMerge mkDefault;
  enableUser = (elem "aarbour" config.cauldron.host.users);
in {
  config = mkMerge [
    (mkIf enableUser {
      users.users.aarbour = {
        uid = mkDefault 1001;
        isNormalUser = true;
        description = "Adam Arbour";
        extraGroups = [ "wheel" "nix" "input" "audio" "video" "plugdev" "networkmanager" "lpadmin" ];
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
    
    # No Secrets
    (mkIf (enableUser && (!config.cauldron.secrets.enable)) {
      users.users.aarbour.initialPassword = "nixos";
    })
  ];
}
