{ pkgs, ... }:
{
  cauldron = {
    profiles = [
      "graphical"
      "gaming"
    ];
    host = {
      boot = {
        kernel = pkgs.unstable.linuxPackages_6_16;
        loader = "systemd";
        silentBoot = true;
      };
      hardware = {
        cpu = "intel";
        gpu = "nvidia";
      };
      network = {
        tailscale.enable = true;
        wireless.backend = "wpa_supplicant";
      };
    };
    secrets.enable = false;
  };
  
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  ### DEVICE SPECIFIC CONFIGURATION
  services.flatpak.enable = false;
  
  # Power Management
  services.thermald.enable = true;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };
  
  # Sound Setup - Default to HDMI. Switch to Headset when found.
  services.pipewire.wireplumber.extraConfig = {
    "10-default-audio" = {
      "monitor.alsa.rules" = [
        { matches = [ { "device.name" = "~alsa_output.*hdmi.*" ; } ];
          actions = { "update-props" = { "device.priority" = 100; }; };
        }
        { matches = [ { "device.name" = "~alsa_output.*usb.*" ; } ];
          actions = { "update-props" = { "device.priority" = 150; }; };
        }
      ];
    };
  };
  
  environment.systemPackages = with pkgs; [
    unigine-superposition
    pegasus-frontend
    intel-undervolt
    lm_sensors
    s-tui
    msr-tools
  ];
}
