{ lib, config, ... }:
let
  inherit (lib) types any flatten mkIf mkMerge mkOption;
  profiles = config.cauldron.profiles;
  
  # Determine if /var/log/journal is being persisted
  impermanence = config.cauldron.host.disk.impermanence;
  
  # Determine role based on configuration and sensible conditions
  role = if cfg.profile != "auto" then cfg.profile else
    if (lib.elem "laptop" profiles) then "laptop" else
    if (lib.elem "server" profiles) then "server" else
    if (lib.elem "container" profiles) || (config.boot.isContainer) then "container" else
    if (lib.elem "kvm" profiles)
      || (config.virtualisation.vmware.guest.enable)
      || (config.virtualisation.virtualbox.guest.enable)
      || (config.virtualisation.hypervGuest.enable)
      || (config.services.qemuGuest.enable) then "kvm" else
    "server";
    
  # Determine storage based on configuration and sensible conditions
  storage = if cfg.mode != "auto" then cfg.mode else
    if role == "server" then "persistent" else
    if role == "laptop" then "persistent" else
    if role == "kvm" then "volatile" else
    if role == "container" then "volatile"
    else "persistent";
    
    # Determine sensible default limits
    defaultsFor = r: rec {
      SystemMaxUse =  if r == "server" then "2G"
                      else if r == "laptop" then "512M"
                      else if r == "kvm" then "256M"
                      else if r == "container" then "128M"
                      else "1G";
      RuntimeMaxUse = if r == "server" then "512M"
                      else if r == "laptop" then "256M"
                      else if r == "kvm" then "192M"
                      else if r == "container" then "96M"
                      else "256M";
      SystemMaxFileSize = "128M";
      RuntimeMaxFileSize = "64M";
      MaxRetentionSec = if r == "server" then "1month" else "2weeks";
      RateLimitIntervalSec = "30s";
      RateLimitBurst = "1000";
      Compress = "yes";
      Seal = "yes";
      ForwardToSysLog = "no";
      ForwardToConsole = "no";
      ForwardToWall = "no";
      SyncIntervalSec = if r == "laptop" then "5m" else "1m";
    };
    d = defaultsFor role;
    
  # Set ramdisk location when storage is ramdisk
  mountRamdisk = storage == "ramdisk";
  
  cfg = config.cauldron.services.journald;
in {  
  options.cauldron.services.journald = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable adaptive journald policy.";
    };
    
    mode = mkOption {
      type = types.enum [ "auto" "persistent" "volatile" "ramdisk" ];
      default = "auto";
      description = "How to store the journal; auto represents impermanence and profile defaults.";
    };
    
    profile = mkOption {
      type = types.enum [ "auto" "server" "laptop" "kvm" "container" ];
      default = "auto";
      description = "Set sensible defaults based on profile (calculated unless set manually).";
    };
    
    path = mkOption {
      type = types.path;
      default = "/var/log/journal";
      description = "Journal directory for persistent storage.";
    };
  };
  
  config = mkIf cfg.enable (mkMerge [
    # Core configuration...
    {
      services.logrotate.enable = true;
      services.journald = {
        storage = if storage == "ramdisk" then "volatile" else storage;
        upload.enable = false;
        extraConfig = ''
          SystemMaxUse=${d.SystemMaxUse}
          RuntimeMaxUse=${d.RuntimeMaxUse}
          SystemMaxFileSize=${d.SystemMaxFileSize}
          RuntimeMaxFileSize=${d.RuntimeMaxFileSize}
          MaxRetentionSec=${d.MaxRetentionSec}
          RateLimitIntervalSec=${d.RateLimitIntervalSec}
          RateLimitBurst=${d.RateLimitBurst}
          Compress=${d.Compress}
          Seal=${d.Seal}
          ForwardToSyslog=${d.ForwardToSysLog}
          ForwardToConsole=${d.ForwardToConsole}
          ForwardToWall=${d.ForwardToWall}
          SyncIntervalSec=${d.SyncIntervalSec}
        '';
      };
    }
    
    # Hande persist directory
    (mkIf (impermanence.enable && storage == "persistent") {
      cauldron.host.impermanence.extra.dirs = [
        "/var/log/journal"
      ];
      systemd.tmpfiles.rules = [
        "d ${cfg.path} 2755 root systemd-journal - -"
      ];
    })
    
    # Handle rammdisk
    (mkIf mountRamdisk {
      fileSystems."${cfg.path}" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "mode=2755" "size=256m" "nosuid" "nodev" "noatime" ];
      };
      users.groups.systemd-journal = {};
      systemd.tmpfiles.rules = [
        "d ${cfg.path} 2755 root systemd-journal - -"
      ];
    })
  ]);
} 
