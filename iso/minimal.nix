{ pkgs, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    { system.installer.channel.enable = false; }
    ./_base_config.nix
  ];
  
  services.getty.autologinUser = "nixos";
}
