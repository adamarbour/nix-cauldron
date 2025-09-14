{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
  nvmeLatencyUs = "3000";
in {
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  boot.blacklistedKernelModules = [ "sp5100_tco" ];
  boot.kernelParams = [
    "amd_prefcore=enable"
    "preempt=full"
    "mem_sleep_default=s2idle"
    "amd_pstate=active"
    "nvme_core.default_ps_max_latency_us=${nvmeLatencyUs}"
    "usbcore.autosuspend=2"
  ];
  boot.kernelModules = [ "thinkpad_acpi" ];
  boot.extraModprobeConfig = ''
    options thinkpad_acpi hotkey_report_mode=2
    options thinkpad_acpi force_load=1
  '';
  
  hardware = {
    brillo.enable = true;
    trackpoint.device = mkDefault "TPPS/2 Elan TrackPoint";
    i2c.enable = true;
  };
  
  systemd.services.set-power-profile = {
    description = "Set default power profile";
    after = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced";
    };
    wantedBy = [ "multi-user.target" ];
  };
  
  systemd.services.ath11k_hibernate = {
    description = "load/unload ath11k to prevent hibernation issues";
    before = [
      "hibernate.target"
      "suspend-then-hibernate.target"
      "hybrid-sleep.target"
    ];
    unitConfig.StopWhenUnneeded = true;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "-${pkgs.kmod}/bin/modprobe -a -r ath11k_pci ath11k";
      ExecStop = "-${pkgs.kmod}/bin/modprobe -a ath11k_pci ath11k";
    };
    wantedBy = [
      "hibernate.target"
      "suspend-then-hibernate.target"
      "hybrid-sleep.target"
    ];
  };
  
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
  '';
  
  systemd.tmpfiles.rules = [ 
    "w /sys/power/image_size - - - - 0"
    "w /sys/devices/platform/smapi/BAT0/start_charge_thresh - - - - 40"
    "w /sys/devices/platform/smapi/BAT0/stop_charge_thresh - - - - 80"
  ];
  
  environment.systemPackages = with pkgs; [ pciutils usbutils tpacpi-bat ];
}
