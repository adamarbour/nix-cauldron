{ lib, pkgs, config, modulesPath, ...}:
let
  inherit (lib) mkIf mkForce mkDefault;
  profiles = config.cauldron.profiles;
in {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  
  config = mkIf (lib.elem "kvm" profiles) {
    boot.initrd.availableKernelModules = [ "ata_piix" "xhci_pci" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_scsi" "virtio_blk" "nvme" ];
    boot.kernelParams = [
      "console=tty1"
      "console=ttyS0,115200"
    ];
    services = {
      smartd.enable = mkForce false;
      thermald.enable = mkForce false;
      qemuGuest.enable = true;
    };
    systemd.services.qemu-guest-agent.path = [ pkgs.shadow ];
  };
}
