{lib, ... }:
let
  inherit (lib) mkDefault;
in {
  # Not using lvm
  services.lvm.enable = mkDefault false;
}
