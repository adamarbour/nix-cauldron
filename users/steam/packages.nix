{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pegasus-frontend
  ];
}
