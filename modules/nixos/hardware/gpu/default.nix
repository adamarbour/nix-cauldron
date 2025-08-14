{ lib, ...}:
let
  inherit (lib) mkOption types;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));
  
  options.cauldron.host.hardware.gpu = mkOption {
    type = types.nullOr (
      types.enum [
        "intel"
        "amd"
        "nvidia"
        "hybrid"
      ]
    );
    default = null;
    description = "Manufacturer of GPU...";
  };
}
