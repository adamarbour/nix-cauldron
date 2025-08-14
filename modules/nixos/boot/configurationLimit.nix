{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  config = {
    boot.loader.grub.configurationLimit = mkDefault 5;
    boot.loader.systemd-boot.configurationLimit = mkDefault 5;
  };
}
