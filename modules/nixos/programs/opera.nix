{ lib, config, pkgs, inputs, ... }:
let

  cfg = config.cauldron.programs.opera;
in {
  # TODO: Handle conditional enablement...
  config = {
    services.flatpak.packages = [
      "com.opera.Opera"
    ];
  };
}