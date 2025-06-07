{ ... }:
{
  config = {
    nix = {
      # disable usage of nix channels
      channel.enable = false;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 3d";
      };
    };
  };
}
