{ lib, config, pkgs, inputs, ... }:
let

  cfg = config.cauldron.programs.ms-edge;
in {
  # TODO: Handle conditional enablement...
  config = {
    services.flatpak.packages = [
      "com.microsoft.Edge"
    ];
  };
}