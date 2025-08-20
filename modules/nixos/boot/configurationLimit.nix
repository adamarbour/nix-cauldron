{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  config = {
    boot.loader.timeout = mkDefault 0;
    boot.loader.grub.configurationLimit = mkDefault 5;
    boot.loader.systemd-boot.configurationLimit = mkDefault 5;
  };
}
