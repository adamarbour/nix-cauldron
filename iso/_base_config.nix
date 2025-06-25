{ lib, pkgs, config, ... }:
{
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault true;
    cpu.amd.updateMicrocode = lib.mkDefault true;
  };
  
  boot = {
    kernelModules = [ "kvm-intel" "kvm-amd" "i915" "amdgpu" "nouveau" ];
    supportedFilesystems = [ "zfs" "btrfs" "xfs" "vfat" "ntfs" "ext4" ];
    tmp.cleanOnBoot = true;
    kernelParams = [ "quiet" "loglevel=3" ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
      systemd.enable = lib.mkDefault (!config.boot.swraid.enable && !config.boot.isContainer);
      systemd.suppressedUnits = lib.mkIf config.systemd.enableEmergencyMode [
        "emergency.service"
        "emergency.target"
      ];
    };
  };

  environment = {
    # Print the URL instead on servers
    variables.BROWSER = "echo";
    # Don't install the /lib/ld-linux.so.2 and /lib64/ld-linux-x86-64.so.2
    # stubs. Server users should know what they are doing.
    stub-ld.enable = lib.mkDefault false;
    ldso32 = null;
    systemPackages = with pkgs; [
      age
      btrfs-progs
      colmena
      curl
      disko
      efibootmgr
      git
      htop
      just
      nixos-install
      nixos-rebuild
      npins
      pciutils
      sbctl
      sops
      ssh-to-age
      tailscale
      usbutils
      wget
      yq-go
    ];
  };
  programs.git.package = lib.mkDefault pkgs.gitMinimal;
  
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    trusted-users = [ "@wheel" ];
  };
  
  time.timeZone = lib.mkDefault "UTC";
  
  networking.hostId = lib.mkDefault "8425e349";
  # Use networkd instead of the pile of shell scripts
  networking.useNetworkd = lib.mkDefault true;
  networking.firewall.enable = false;
  networking.usePredictableInterfaceNames = false;
  
  # No mutable users by default
  users.mutableUsers = false;
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.bashInteractive;
  };
  
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
  systemd.services.systemd-networkd.stopIfChanged = false;
  systemd.services.systemd-resolved.stopIfChanged = false;
  
  security.sudo.execWheelOnly = true;
  security.sudo.wheelNeedsPassword = false;
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
  
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  services.openssh = {
    enable = true;
    settings.X11Forwarding = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PasswordAuthentication = false;
    settings.UseDns = false;
    settings.StreamLocalBindUnlink = true;
    settings.KexAlgorithms = [
      "curve25519-sha256"
      "curve25519-sha256@libssh.org"
      "diffie-hellman-group16-sha512"
      "diffie-hellman-group18-sha512"
      "sntrup761x25519-sha512@openssh.com"
    ];
  };
  
  fonts.fontconfig.enable = lib.mkDefault false;
  documentation.enable = lib.mkDefault false;
  documentation.doc.enable = lib.mkDefault false;
  documentation.info.enable = lib.mkDefault false;
  documentation.man.enable = lib.mkDefault false;
  
  environment.etc."tailscale.key".source = ./tailscale.key;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraDaemonFlags = [ "--no-logs-no-support" ];
    extraUpFlags = [ "--ssh" ];
    authKeyFile = "/etc/tailscale.key";
  };
  
  systemd = {
    enableEmergencyMode = false;
    watchdog = {
      runtimeTime = lib.mkDefault "15s";
      rebootTime = lib.mkDefault "30s";
      kexecTime = lib.mkDefault "1m";
    };
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };
  virtualisation.vmVariant.virtualisation.graphics = lib.mkDefault false;
  
  system.stateVersion = "24.11";
}
