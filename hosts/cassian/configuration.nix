{ pkgs, sources, ... }:
{
  cauldron = {
    profiles = [
      "graphical"
      "laptop"
      "workstation"
      "gaming"
    ];
    host = {
      boot = {
        loader = "secure";
        silentBoot = true;
      };
      hardware = {
        cpu = "intel";
        gpu = "hybrid";
      };
      network = {
        wireless.backend = "wpa_supplicant";
        tailscale.enable = true;
        wireguard.tunnels = {
          "arbour-cloud" = {
            addresses = [ "172.31.7.11/24" ];
            privateKey = { kind = "sops"; path = "wg/cassian.key"; };
            routes = [ "172.31.7.0/24" ];
          };
          "work-cloud" = {
            addresses = [ "10.10.10.11/24" ];
            privateKey = { kind = "sops"; path = "wg/cassian-2.key"; };
            routes = [ "172.31.7.0/24" ];
          };
        };
      };
      feature = {
        crossbuild = {
          enable = true;
          emulatedSystems = [ "aarch64-linux" ];
          extraPlatforms = [ "aarch64-linux" ];
        };
        printing.enable = true;
        bluetooth = true;
        thunderbolt = true;
        tpm = true;
        winbox = true;
      };
    };
    secrets.enable = true;
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

}
