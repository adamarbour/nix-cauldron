{ lib, config, pkgs, inputs, ... }:
let
  inherit (lib.modules) mkIf mkDefault;

  cfg = config.cauldron.security.yubikey;
in {
  # TODO: Enable this if the yubikey-agent is enabled.
  config = {
    services = {
      pcscd.enable = true;
      udev.packages = with pkgs; [ yubikey-personalization ];
    };

    environment.systemPackages = with pkgs; [ 
      yubioath-flutter
      yubikey-manager
      yubikey-touch-detector
      yubico-piv-tool
    ];
  };
}