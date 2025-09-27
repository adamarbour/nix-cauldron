{ lib, config, ... }:
{
  config = {
    services.ssh-agent = {
      enable = true;
      defaultMaximumIdentityLifetime = 1337;
    };
  };
}
