{ lib, ...}:
let
  inherit (lib) mkOption types;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));
  
  options.cauldron.host.cpu = mkOption {
    type = types.nullOr (
      types.enum [
        "intel"
        "vm-intel"
        "amd"
        "vm-amd"
      ]
    );
    default = null;
    description = "Manufacturer of CPU...";
  };
}
