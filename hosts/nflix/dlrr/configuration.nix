{ lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  cauldron = {
    host.cpu = "intel";
    host.boot = {
      loader = "grub";
      grub = {
        enableEFI = false;
        device = "/dev/vda";
      };
    };
     
     profiles = [ "server" ];
     services.cloud-init.enable = true;
  };
}
