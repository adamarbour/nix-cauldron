{ lib, sources, ... }:
{
  programs.git = {
    enable = true;
    lfs = {
      enable = true;
      skipSmudge = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      repack.usedeltabaseoffset = "true";
      color.ui = "auto";
      help.autocorrect = 10;
      
      # QoL
      branch = {
        autosetupmerge = "true";
        sort = "committerdate";
      };
      
      commit.verbose = true;
      fetch.prune = true;
      
      # prevent data corruption
      transfer.fsckObjects = true;
      fetch.fsckObjects = true;
      receive.fsckObjects = true;
    };
  };
}
