{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.make.services.fwupd;
in
{
  options.make.services.fwupd = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable fwupd.";
      default = false;
    };
  };

  config = {
    services.fwupd = {
      enable = cfg.enable;
      daemonSettings.EspLocation = config.boot.loader.efi.efiSysMountPoint;
    };
  };
}