{ pkgs, ... }:
{
  cauldron = {
    profiles = [
      "desktop"
      "graphical"
      "gaming"
    ];
    host = {
      boot = {
        kernel = pkgs.linuxPackages_xanmod_stable;
        loader = "systemd";
        silentBoot = true;
      };
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/nvme1n1";
        impermanence = {
          enable = true;
          rootSize = "1G";
        };
        swap.enable = true;
      };
      hardware = {
        cpu = "intel";
        gpu = "nvidia";
      };
      network = {
        wireless.backend = "wpa_supplicant";
        tailscale.enable = true; 
        wireguard.tunnels = {
          "arbour-cloud" = {
            addresses = [ "172.31.7.103/24" "2001:db8:ac::103/64"];
            privateKey = { kind = "sops"; path = "wg/lucien.key"; };
            routes = [
              { Destination = "172.31.7.0/24"; }
              { Destination = "2001:db8:ac::0/64"; }
            ];
          };
        };
      };
      impermanence = {
        root = "/persist";
      };
    };
    secrets.enable = true;
  };
  
  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;
  
  ### DEVICE SPECIFIC CONFIGURATION
  services.flatpak.enable = false;
}
