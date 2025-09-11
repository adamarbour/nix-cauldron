{ lib, config, ... }:

let
  inherit (lib) mkIf optional hasInfix findFirst;
  profiles = config.cauldron.profiles;
  
  # Scheduler configurations with priority order
  schedulerConfigs = {
    laptop = {
      scheduler = "scx_bpfland";
      description = "Low-latency scheduler optimized for gaming workloads";
      extraArgs = [ "-m powersave" ];
      priority = 10;
    };
    gaming = {
      scheduler = "scx_bpfland";
      description = "Low-latency scheduler optimized for gaming workloads";
      extraArgs = [ "-m performance" ];
      priority = 20;
    };
    server = {
      scheduler = "scx_bpfland";
      description = "Rust-based scheduler optimized for server workloads";
      extraArgs = [ "-p" ];
      priority = 30;
    };
    hypervisor = {
      scheduler = "scx_bpfland";
      description = "Compute-optimized scheduler for hypervisor workloads";
      extraArgs = [ "-p" ];
      priority = 40;
    };
    remote-builder = {
      scheduler = "scx_bpfland";
      description = "Compute-optimized scheduler for build workloads";
      extraArgs = [ "-p" ];
      priority = 50;
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
