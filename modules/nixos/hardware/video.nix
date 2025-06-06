{ lib, ... }:
let
  inherit (lib) mkIf;
in {
  # TODO: If it is a graphic profile
  config = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
