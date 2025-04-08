{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.environment;
in {
  config = {
    hardware.enableRedistributableFirmware = true;
  };
}