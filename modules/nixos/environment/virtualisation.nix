{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  virtualisation.vmVariant.virtualisation.graphics = mkDefault false;
}
