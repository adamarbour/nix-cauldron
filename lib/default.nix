{ lib, ... }:
let
  inherit (lib) mkIf;
in {
  hasProfile = config: profile: builtins.elem profile (config.cauldron.profiles or []);
  mkIfProfile = config: profile: x: mkIf (builtins.elem profile (config.cauldron.profiles or [])) x;
}
