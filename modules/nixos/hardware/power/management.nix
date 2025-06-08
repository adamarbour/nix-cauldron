{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkForce;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "laptop" profiles) {
    services = {
      thermald.enable = config.cauldron.host.cpu == "intel";
      system76-scheduler.settings.cfsProfiles.enable = true;
      power-profiles-daemon.enable = mkForce false;
      auto-cpufreq.enable = mkForce false;
    };
    powerManagement.powertop.enable = true;
  };
}
