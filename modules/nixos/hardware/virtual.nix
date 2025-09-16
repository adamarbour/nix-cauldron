{ lib, pkgs, config, modulesPath, ...}:
let
  inherit (lib) mkIf mkForce mkDefault;
  inherit (lib.cauldron) hasProfile;
in {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  
  config = mkIf (hasProfile config "kvm") {
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
