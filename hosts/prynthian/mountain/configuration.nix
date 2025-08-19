{ pkgs, ... }:
let
  device = "/dev/disk/by-id/nvme-SPCC_M.2_PCIe_SSD_509D074B162300138574";
in {
  cauldron = {
    profiles = [
      "server"
    ];
    host = {
      boot = {
        kernel = pkgs.linuxPackages;
        loader = "systemd";
      };
      hardware.cpu = "intel";
      network = {
        tailscale.enable = true;
      };
      disk = {
        enable = true;
        rootFs = "zfs";
        inherit device;
        impermanence.enable = true;
      };
    };
    secrets.enable = false;
  };
}
