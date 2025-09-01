{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    fd
    fzf
    just
    procs
    ripgrep
    tldr
    yq-go
  ];
}
