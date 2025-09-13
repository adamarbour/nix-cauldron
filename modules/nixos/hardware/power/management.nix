{ lib, config, ... }:
let
  inherit (lib) mkIf mkForce mkDefault;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "laptop" profiles) {
    services = {
      thermald.enable = config.cauldron.host.hardware.cpu == "intel";
      power-profiles-daemon.enable = mkForce true;
      tlp.enable = mkForce false;
      auto-cpufreq.enable = mkForce false;
    };
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
    };
    systemd.tmpfiles.rules = [
      "f /sys/class/rtc/rtc0/wakealarm 0664 root root -"
    ];
  };
}
