{ lib, pkgs, ... }:
{
  cauldron = {
    host = {
      boot = {
        kernel = pkgs.linuxPackages;
        loader = "grub";
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
      impermanence = {
        extra.dirs = [
          "/var/lib/transmission"
        ];
      };
      network = {
        wireguard.tunnels = {
          "nflix" = {
            publicKey = "MRpOWd8l8dCgW3akz2RDUGOw+NBwe81fEXE74mPRglM=";
            privateKey = { kind = "sops"; path = "wg/dlrr.key"; };
            endpoint = "wg.nflix.lol";
            listenPort = 51820;
            addresses = [ "10.11.12.254/32" ];
            openFirewall = true;
            enableIPForward = true;
          };
        };
      };
    };
    services = {
      transmission = {
        enable = true;
        rpcInterface = "wg-nflix";
        rpcBindIPv4 = "10.11.12.254";
        rpcReqAuth = false;
        cacheSize   = 32;   # MiB; try 24–64 if needed
        peerLimit   = 200;  # global
        peerLimitPT = 40;   # per torrent
        extraSettings = {
          "preallocation"    = 1;
          "prefetch-enabled" = false;
          # Downloading
          "peer-socket-tos"           = "throughput";
          "upload-slots-per-torrent"  = 14;
          "download-queue-enabled"    = true;
          "download-queue-size"       = 3;
          "queue-stalled-enabled"     = true;
          "queue-stalled-minutes"     = 30;
          # Seeding
          "ratio-limit-enabled"         = true;
          "ratio-limit"                 = 2.5;
          "idle-seeding-limit-enabled"  = true;
          "idle-seeding-limit"          = 20160;
          "seed-queue-enabled"          = true;
          "seed-queue-size"             = 5;
          # Blocklist
          "blocklist-enabled" = true;
          "blocklist-url"     = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";
        };
      };
    };
    secrets.enable = true;
  };
}
