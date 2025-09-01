{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault;
in {
  config ={
    home-manager.users.steam = import ./steam;
    users.users.steam = {
      isNormalUser = true;
      initialPassword = "steam";
      extraGroups = [ "video" "audio" "input" "networkmanager" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYiOynu6CwX4zHlSNxc0H4MkpseEhoGCOL6ls+laxdc aarbour"
      ];
      shell = pkgs.bashInteractive;
    };
    # Impermanence additions...
    cauldron.host.impermanence.users.steam = {
      extraDirs = [
        "Downloads"
        ".steam"
        ".local/share/Steam"
        ".local/share/applications"
        ".config/pegasus-frontend"
      ];
      extraFiles = [];
    };
  };
}
