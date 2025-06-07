{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  users.users.aarbour = {
    uid = mkDefault 1000;
    isNormalUser = true;
    home = "/home/aarbour";
    createHome = true;
    description = "Adam Arbour";
    
    extraGroups = [
      "wheel"
      "nix"
    ];
    initialPassword = "nixos"; #TODO: Replace with secrets...
    openssh.authorizedKeys.keys = [
      # TODO: Fix...
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAc2MLBtYJd5b95ezUrHuZoENM50ETU8Un21lQa01eCq"
    ];
  };
}
