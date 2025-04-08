{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.host.boot;
in {
  config = mkIf (cfg.loader == "none") {
    boot.loader = {
      grub.enable = mkForce false;
      systemd-boot.enable = mkForce false;
    };
  };
}