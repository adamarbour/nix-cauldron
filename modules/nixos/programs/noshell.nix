{ sources, ... }:
{
  imports = [
    (sources.noshell + "/module.nix")
  ];
  programs.noshell.enable = true;
}
