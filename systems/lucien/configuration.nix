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
            publicKey = "zFMgPfln0vDOWZkSWDOk/SNt+J1hn1pbKHOVjDrMNhU=";
            privateKey = { kind = "sops"; path = "wg/lucien.key"; };
            addresses = [ "172.31.7.103/32" "2001:db8:ac::103/128"];
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
