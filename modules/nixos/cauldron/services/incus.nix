{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.make.services.incus;
in
{
  options.make.services.incus = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable incus.";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.incus = {
      enable = true;

    };
    networking.firewall.trustedInterfaces = [ "incusbr0" ];
  };
}