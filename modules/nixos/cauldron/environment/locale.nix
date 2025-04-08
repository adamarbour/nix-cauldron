{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.environment;
in {
  
  options.make.environment = {
    # TODO: Option expansion
  };

  config = {
    # UTC everywhere!
    time.timeZone = mkDefault "UTC";
    # USA! USA!
    i18n.defaultLocale = mkDefault "en_US.UTF-8";
  };
}