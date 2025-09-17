{ lib, pkgs, ... }:
{
  cauldron = {
    profiles = [
      "server"
      "kvm"
    ];
    host = {
      boot = {
        kernel = pkgs.linuxPackages;
        loader = "systemd";
      };
      hardware.cpu = "intel";
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/vda";
        impermanence = {
          enable = true;
          rootSize = "1G";
        };
        swap.enable = true;
      };
      network = {
        wireguard.tunnels = {
          "nflix" = {
            addresses = [ "10.11.12.254/24" ];
            privateKey = { kind = "sops"; path = "wg/dlrr.key"; };
            listenPort = 51820;
            openFirewall = true;
            enableIPForward = true;
          };
        };
      };
    };
    services = {
      transmission = {
        enable = true;
        dataDir = "/srv/media/transmission";
        downloadDir = "/srv/media/Downloads";
        rpcInterface = "wg-nflix";
        rpcBindIPv4 = "10.11.12.254";
        rpcReqAuth = false;
        cacheSize = 128;
        peerLimit = 2000;
        peerLimitPT = 200;
        extraSettings = {
          "preallocation" = 1;
          # Downloading
          "peer-socket-tos" = "throughput";
          "upload-slots-per-torrent" = 14;
          "download-queue-enabled" = true;
          "download-queue-size" = 10;
          "peer-congestion-algorithm" = "cubic";
          # Seeding
          "seedRatioLimited" = true;
          "seedRatioLimit" = 2.0;
          "idle-seeding-limit-enabled" = true;
          "idle-seeding-limit" = 20160;
          "seed-queue-enabled" = true;
          "seed-queue-size" = 10;
        };
      };
      cloud-init = {
        enable = true;
        dataSources = [ "NoCloud" ];
      };
    };
    secrets.enable = true;
  };
  
  # System level tweaks 
  # TODO: Move to configuration at some point.
  boot.kernel.sysctl = lib.mkForce {
    "net.core.rmem_max" = 67108864;
    "net.core.wmem_max" = 67108864;
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";
    "net.ipv4.tcp_congestion_control" = "cubic";
  };
}
