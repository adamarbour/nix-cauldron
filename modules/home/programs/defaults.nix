{ lib, config, ... }:
let
  inherit (lib) types mkOption mapAttrs;
  mkDefault = name: args: mkOption ({ description = "default ${name} for the system"; } // args);
in {
  options.cauldron.programs.defaults = mapAttrs mkDefault {
    shell = {
      type = types.enum [
        "bash"
        "zsh"
        "fish"
        "nushell"
      ];
      default = "bash";
    };
    terminal = {
      type = types.enum [
        "ghostty"
        "rio"
      ];
      default = "ghostty";
    };
#    windowManager =
#    screenLocker = 
#    appLauncher =
#    bar =
#    fileManager =
#    webBrowser =
#    editor =
    pager = {
      type = types.str;
      default = "less -FR";
    };
  };
}
