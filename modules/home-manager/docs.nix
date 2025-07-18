{ lib, config, sources, ... }:
let
  inherit (lib) mkDefault;
in {
  config = {
    manual = {
      html.enable = false;
      json.enable = false;
      manpages.enable = false;
    };
  };
}
