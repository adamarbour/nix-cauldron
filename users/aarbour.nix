{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault;
in {
  config = mkMerge [
    {
      home-manager.users.aarbour = import ./aarbour;
      users.users.aarbour = {
        uid = mkDefault 1001;
        isNormalUser = true;
        description = "Adam Arbour";
        extraGroups = [ "wheel" "nix" "audio" "video" "networkmanager" "lpadmin" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYiOynu6CwX4zHlSNxc0H4MkpseEhoGCOL6ls+laxdc aarbour"
        ];
      };
    }
    
    # Impermanence
    (mkIf config.cauldron.host.disk.impermanence.enable {
      systemd.tmpfiles.rules = [
        "d /persist/users/aarbour 0700 aarbour users -"
      ];
    })
    
    # Secrets
    (mkIf config.cauldron.secrets.enable {
      users.users.aarbour.hashedPasswordFile = config.sops.secrets.passwd.path;
    })
    
    # No Secrets
    (mkIf (!config.cauldron.secrets.enable) {
      users.users.aarbour.initialPassword = "nixos";
    })
  ];
}
