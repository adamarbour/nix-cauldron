{ lib, config, pkgs, ... }:
let

in {
  config = {
    services.ssh-agent.enable = true;
  };
}