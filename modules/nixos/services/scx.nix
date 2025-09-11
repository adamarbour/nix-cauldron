{ lib, config, ... }:

let
  inherit (lib) mkIf optional hasInfix findFirst;
  profiles = config.cauldron.profiles;
  
  # Scheduler configurations with priority order
  schedulerConfigs = {
    gaming = {
      scheduler = "scx_lavd";
      description = "Low-latency scheduler optimized for gaming workloads";
      extraArgs = [ "--slice-us" "20000" ];
      priority = 10;
    };
    server = {
      scheduler = "scx_rusty";
      description = "Rust-based scheduler optimized for server workloads";
      extraArgs = [ "--nr-cpus" "0" ];
      priority = 20;
    };
    hypervisor = {
      scheduler = "scx_lavd";
      description = "Compute-optimized scheduler for hypervisor workloads";
      extraArgs = [ "--slice-us" "50000" ];
      priority = 30;
    };
    remote-builder = {
      scheduler = "scx_lavd";
      description = "Compute-optimized scheduler for build workloads";
      extraArgs = [ "--slice-us" "50000" ];
      priority = 40;
    };
    default = {
      scheduler = "scx_rustland";
      description = "General purpose scheduler for desktop workloads";
      extraArgs = [];
      priority = 999;
    };
  };
  
  # Find the highest priority profile that's enabled
  selectedProfile = 
    let
      enabledProfiles = lib.filter (p: lib.elem p profiles) (lib.attrNames schedulerConfigs);
      profilesWithPriority = map (p: { name = p; config = schedulerConfigs.${p}; }) enabledProfiles;
      sortedProfiles = lib.sort (a: b: a.config.priority < b.config.priority) profilesWithPriority;
    in
      if sortedProfiles != [] 
      then (lib.head sortedProfiles).config
      else schedulerConfigs.default;

  # Check if kernel supports sched-ext
  kernelSupportsSchedExt = 
    config.boot.kernelPackages.kernel.isZen ||
    config.boot.kernelPackages.kernel.isHardened ||
    hasInfix "sched-ext" (config.boot.kernelPackages.kernel.version or "");

in {
  config = mkIf (!config.boot.isContainer) {
    services.scx = {
      enable = true;
      scheduler = selectedProfile.scheduler;
      extraArgs = selectedProfile.extraArgs;
    };
    
    boot.kernel.sysctl."kernel.sched_autogroup_enabled" = 0;
    
    warnings = optional (!kernelSupportsSchedExt) 
      "SCX schedulers require sched-ext kernel support. Current profiles: [${lib.concatStringsSep ", " profiles}] → ${selectedProfile.scheduler}";
  };
}
