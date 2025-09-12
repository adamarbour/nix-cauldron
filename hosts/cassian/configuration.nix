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
            addresses = [ "172.31.7.11/24" "2001:db8:ac::11/64"];
            privateKey = { kind = "sops"; path = "wg/cassian.key"; };
            routes = [
              { Destination = "172.31.7.0/24"; }
            ];
          };
          "nflix" = {
            addresses = [ "10.11.12.1/24" ];
            privateKey = { kind = "sops"; path = "wg/cassian.key"; };
            routes = [
              { Destination = "10.11.12.0/24"; }
            ];
          };
        };
      };
      feature = {
        crossbuild = {
          enable = true;
          emulatedSystems = [ "aarch64-linux" ];
          extraPlatforms = [ "i686-linux" "aarch64-linux" ];
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
