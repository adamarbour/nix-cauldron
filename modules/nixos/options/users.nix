{ lib, config, ... }:
let
  inherit (lib) types optional mkOption;
in {
  options.cauldron.system = {
    mainUser = mkOption {
      type = types.enum config.cauldron.system.users;
      default = builtins.elemAt config.cauldron.system.users 0;
      description = "The primary user of the system.";
    };
    users = mkOption {
      type = types.listOf types.str;
      default = [ "aarbour" ];
      description = ''
        A list of non-system users that should be declared for the host. The first user in the list will
        be treated as the Main User unless {option}`cauldron.system.mainUser` is set.
      '';
    };
  };
  config = {
    warnings = optional (config.cauldron.system.users == []) ''
      You have not added any users to be supported by your system.
      
      Consider setting {option}`config.cauldron.host.users` in your configuration.
    '';
  };
}
