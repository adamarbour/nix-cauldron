{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault;
in {
  config = mkMerge [
    {
      home-manager.users.steam = import ./steam;
      users.users.steam = {
        isNormalUser = true;
        initialPassword = "steam";
        extraGroups = [ "video" "input" "audio" "networkmanager" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYiOynu6CwX4zHlSNxc0H4MkpseEhoGCOL6ls+laxdc aarbour"
        ];
        shell = pkgs.bashInteractive;
      };
    }
    
    # Impermanence
    (mkIf config.cauldron.host.disk.impermanence.enable {
      systemd.tmpfiles.rules = [
        "d /persist/users/home/steam 0700 steam users -"
      ];
    })
  ];
}
