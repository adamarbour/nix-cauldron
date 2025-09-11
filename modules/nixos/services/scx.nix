{ lib, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf ((lib.elem "desktop" profiles) || (lib.elem "laptop" profiles)) {
    services.scx = {
      enable = true;
      scheduler = if (lib.elem "gaming" profiles) then "scx_rustland" else "scx_layered";
    };
  };
}
