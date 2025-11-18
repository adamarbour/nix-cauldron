{ lib, config, osConfig, ... }:
{
  config = {
    programs.ssh = {
      enable = osConfig.services.openssh.enable;
      addKeysToAgent = "yes";

      hashKnownHosts = true;
      userKnownHostsFile = "~/.ssh/known_hosts";

      matchBlocks = {
        "*" = {
          forwardAgent = false;
          compression = true;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
        };
      };
    };

    services.ssh-agent.enable = osConfig.services.openssh.enable;
  };
}
