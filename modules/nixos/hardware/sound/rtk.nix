{ lib, config, ...}:
let
  inherit (lib) mkForce;
in {
  security.rtkit.enable = mkForce config.services.pipewire.enable;
}
