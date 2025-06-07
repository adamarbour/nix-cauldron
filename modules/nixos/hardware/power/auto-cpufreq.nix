{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkDefault mkForce;
  MHz = x: x * 1000;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "laptop" profiles) {
    services = {
      auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            energy_performance_preference = "power";
            scaling_min_freq = mkDefault (MHz 1200);
            scaling_max_freq = mkDefault (MHz 2600);
            turbo = "never";
            
            enable_thresholds = true;
            start_threshold = 20;
            stop_threshold = 80;
          };
          charger = {
            governor = "performance";
            energy_performance_preference = "performance";
            scaling_min_freq = mkDefault (MHz 2200);
            scaling_max_freq = mkDefault (MHz 4800);
            turbo = "auto";
          };
        };
      };
      power-profiles-daemon.enable = mkForce false;
    };
  };
}
