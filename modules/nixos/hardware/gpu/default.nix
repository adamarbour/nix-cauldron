{ lib, ... }:
let
  inherit (lib) mkOption types;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));
  
  options.cauldron.host.gpu = mkOption {
    type = types.nullOr (
      types.enum [
        "amd"
        "intel"
        "nvidia"
        "intel-nv"
        "amd-nv"
      ]
    );
    default = null;
    description = "Manufacturer of GPU... intel-nv/amd-nv for PRIME";
  };
}
