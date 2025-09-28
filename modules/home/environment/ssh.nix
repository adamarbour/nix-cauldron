{ lib, config, ... }:
{
  config = {
    services.ssh-agent.enable = true;
  };
}
