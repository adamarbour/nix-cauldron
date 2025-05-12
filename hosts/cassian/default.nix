{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    (import ../luks-btrfs-imp.nix { device = "/dev/nvme0n1"; })
  ];
  
  networking.hostName = "cassian";
  
  
  programs.fuse.userAllowOther = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/etc/secureboot/"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/flatpak"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  environment.systemPackages = with pkgs; [
    sbctl
    pciutils
    usbutils
    neovim
    neovide
    v4l-utils
    cameractrls-gtk4
    obsidian
#    rofi-obsidian
    solaar
    vscodium
    kitty
  ];
  
  users.users."aarbour" = {
    isNormalUser = true;
    initialPassword = "nixos";
    hashedPasswordFile = config.sops.secrets.my_password.path;
    extraGroups = [ 
      "wheel"
      "gamemode"
    ];
    openssh.authorizedKeys.keyFiles = with inputs; [ my-keys.outPath ];
  };

  programs.dconf.enable = true;
  programs.firefox.enable = true;

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerdfonts
  ];

  cauldron.services.tailscale.enable = false;

  cauldron.environment.timeZone = "America/Chicago";
  cauldron.environment.hostPlatform = "x86_64-linux";

  cauldron.services.lightdm.enable = true;
  cauldron.services.xfce.enable = true;
}

