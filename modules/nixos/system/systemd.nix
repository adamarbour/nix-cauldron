{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in {
  systemd = {
    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;
    
    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 7.5s.
      # If the hardware watchdog does not get a signal for 15s,
      # it will forcefully reboot the system.
      runtimeTime = mkDefault "15s";
      
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = mkDefault "30s";
      
      # Forcefully reboot when a host hangs after kexec.
      # This may be the case when the firmware does not support kexec.
      kexecTime = mkDefault "1m";
    };
    sleep = mkIf (lib.elem "server" profiles) {
      extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };
  };
}
