{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  # enable smartd monitoring
  services.smartd.enable = mkDefault true;
}
