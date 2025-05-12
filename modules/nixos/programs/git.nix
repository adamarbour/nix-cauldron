{ lib, config, inputs, ... }:
let

  cfg = config.cauldron.programs.git;
in {
  config = {
    programs.git = {
      enable = true;
      lfs.enable = true;
      config = {
        init.defaultBranch = "main";
      };
    };
  };
}