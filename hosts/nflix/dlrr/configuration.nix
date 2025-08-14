{ pkgs, ... }:
{
  cauldron = {
    profiles = [
      "server"
      "kvm"
    ];
    host = {
      boot.loader = "grub";
      hardware.cpu = "intel";
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/vda";
        swap.enable = true;
      };
    };
    services = {
      cloud-init.enable = true;
    };
  };
}
