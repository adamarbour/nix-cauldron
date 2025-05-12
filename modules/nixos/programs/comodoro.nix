{ lib, config, pkgs, inputs, ... }:
let

  cfg = config.cauldron.programs.comodoro;
in {
  # TODO: Handle conditional enablement...
  config = {
    environment.systemPackages = with pkgs; [
      comodoro
    ];
  };
}