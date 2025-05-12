{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkDefault;

  cfg = config.cauldron.environment;
in {

  imports = [
    (lib.mkAliasOptionModule [ "cauldron" "environment" "timeZone" ] [ "time" "timeZone" ])
  ];

  config = {
    time.timeZone = mkDefault "UTC";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
}