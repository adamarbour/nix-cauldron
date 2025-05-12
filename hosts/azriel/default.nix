{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./hardware.nix
    (import ../luks-btrfs-imp.nix { device = "/dev/nvme0n1"; })
  ];

  networking.hostName = "azriel";
  # Set your time zone.
  time.timeZone = "America/Chicago";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  users.users."aarbour" = {
    isNormalUser = true;
    initialPassword = "nixos";
    extraGroups = [ "wheel" ];
  };
}