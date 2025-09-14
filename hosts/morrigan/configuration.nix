{ pkgs, sources, ... }:
{
  cauldron = {
    profiles = [
      "graphical"
      "laptop"
      "workstation"
    ];
    host = {
      boot = {
        kernel = pkgs.linuxPackages_zen;
        loader = "systemd";
        silentBoot = true;
      };
      hardware = {
        cpu = "amd";
        gpu = "amd";
      };
      disk = {
        enable = true;
        encrypt = true;
        rootFs = "btrfs";
        device = "/dev/nvme0n1";
        impermanence = {
          enable = true;
          rootSize = "1G";
        };
      };
      network = {
        wireless.backend = "iwd";
         wireguard.tunnels = {
          "arbour-cloud" = {
            addresses = [ "172.31.7.13/24" "2001:db8:ac::13/64"];
            privateKey = { kind = "sops"; path = "wg/morrigan.key"; };
            routes = [
              { Destination = "172.31.7.0/24"; }
            ];
          };
          "nflix" = {
            addresses = [ "10.11.12.2/24" ];
            privateKey = { kind = "sops"; path = "wg/morrigan.key"; };
            routes = [
              { Destination = "10.11.12.0/24"; }
            ];
          };
        };
      };
      feature = {
        touchscreen = {
          enable = true;
          sensors = true;
        };
        fprint.enable = true;
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
