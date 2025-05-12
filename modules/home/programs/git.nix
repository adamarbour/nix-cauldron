{ lib, config, pkgs, ... }:
let

in {
  config = {
    programs.git = {
      enable = true;
      userEmail = "845679+adamarbour@users.noreply.github.com";
      userName = "Adam Arbour";
    };
  };
}