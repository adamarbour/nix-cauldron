{ config, ... }:
{
  sops.secrets = {
    age_key = {
      path = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
  };
}
