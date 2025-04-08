{ inputs, flake, pkgs, ... }:
{
  imports = [
    flake.nixosModules.cauldron
    ./build-container.nix
  ];

  disko.devices = import ./disk.nix;

  make.system.type = "x86_64-linux";
  make.host.boot.loader = "systemd-boot";
  make.services.sshd.enable = true;

  make.home.enable = true;

  # TEMP
  users.users.aarbour = {
    isNormalUser = true;
    extraGroups = [ "wheel " ];
    initialPassword = "nixos";
    openssh.authorizedKeys.keyFiles =  with inputs; [ my-keys.outPath ];
  };
}