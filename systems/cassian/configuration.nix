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
            publicKey = "/wYcBIwBvnPbVJqSN7o/EJIazS6lc9KaVnzjtl6Vc3s=";
            privateKey = { kind = "sops"; path = "wg/cassian.key"; };
            addresses = [ "172.31.7.102/32" "2001:db8:ac::102/128"];
            routes = [
              { Destination = "172.31.7.0/24"; }
              { Destination = "2001:db8:ac::/64"; }
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
