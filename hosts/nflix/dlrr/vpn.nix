{ lib, pkgs, config, ... }:
let
  ip = "${pkgs.iproute2}/bin/ip";
  transmission = config.cauldron.services.transmission;
in {
  # Policy-based routing (RPDB)
  networking.iproute2 = {
    enable = true;
    rttablesExtraConfig = ''
      51821 proton
    '';
  };
  
  # pbr-transmission-proton: add/remove the uid-based rule when wg-proton is up/down
  systemd.services."pbr-transmission-proton" = {
    description = "Policy route Transmission (UID 3003) via wg-proton";
    # Start only when the wg-proton link (device unit) exists; stop when it disappears.
    bindsTo = [ "sys-subsystem-net-devices-wg\\x2dproton.device" ];
    after   = [
      "systemd-networkd.service"
      "sys-subsystem-net-devices-wg\\x2dproton.device"
      "pbr-transmission-proton-route.service"
    ];
    partOf  = [ "systemd-networkd.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Be conservative if this races early at boot
      ExecStartPre = "${ip} link show dev wg-proton";
    };

    script = ''
      set -euo pipefail
      # (Re)create the rule when wg-proton is present
      ${ip} rule del uidrange 3003-3003 lookup 51821 2>/dev/null || true
      ${ip} rule add uidrange 3003-3003 lookup 51821 priority 10000
    '';

    preStop = ''
      set -euo pipefail
      ${ip} rule del uidrange 3003-3003 lookup 51821 2>/dev/null || true
    '';

    wantedBy = [ "multi-user.target" ];
  };
  
  systemd.services."pbr-transmission-proton-route" = {
    description = "Ensure default route in table 51821 for wg-proton";
    bindsTo = [ "sys-subsystem-net-devices-wg\\x2dproton.device" ];
    after   = [ "systemd-networkd.service" "sys-subsystem-net-devices-wg\\x2dproton.device" ];
    partOf  = [ "systemd-networkd.service" ];
    serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    script = ''
      set -euo pipefail
      # Add (or refresh) the default in table 51821, onlink for /32
      ${ip} route replace default via 10.2.0.1 dev wg-proton table 51821 onlink
      ${ip} route replace 10.11.12.0/24 dev wg-nflix table 51821
    '';
    preStop = ''
      set -euo pipefail
      ${ip} route flush table 51821 || true
    '';
    wantedBy = [ "multi-user.target" ];
  };

  # Killswitch
  networking.nftables.tables.transmission_ipv6_drop = {
    family = "inet";
    content = ''
      chain output {
        type filter hook output priority 0; policy accept;

        # Allow loopback for the daemon itself
        meta skuid 3003 oifname "lo" accept

        # Drop ANY IPv6 packet from Transmission (UID 3003)
        meta skuid 3003 meta nfproto ipv6 drop
      }
    '';
  };
  
  networking.nftables.tables.transmission_peer = {
    family = "inet";
    content = ''
      # A dynamic set we can update from the service
      set t_peer {
        type inet_service
        flags timeout
      }

      chain input {
        type filter hook input priority -90;
        iifname "wg-proton" tcp dport @t_peer accept
        iifname "wg-proton" udp dport @t_peer accept
      }
    '';
  };
  
  # Proton VPN private-key
  sops.secrets.wg_proton = {
    owner = "systemd-network";
    group = "systemd-network";
    mode  = "0400";
    restartUnits = [ "systemd-networkd.service" ];
  };
  # Proton VPN wireguard configuration
  systemd.network.netdevs."wg-proton" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg-proton";
      MTUBytes = "1300";
    };
    wireguardConfig = {
      PrivateKeyFile = "/run/secrets/wg_proton";
      ListenPort = 9918;
    };
    wireguardPeers = [
      {
        PublicKey = "buYqE3X8Wf8X/v5NtHVXYgLk45+2og8MVEbgQAkEyBw=";
        AllowedIPs = [ "0.0.0.0/0" "::/0" ];
        Endpoint = "79.135.104.48:51820";
        RouteTable = 51821;
        RouteMetric = 50;
      }
    ];
  };
  systemd.network.networks."wg-proton" = {
    matchConfig.Name = "wg-proton";
    addresses = [ { Address = "10.2.0.2/32"; } ];
    routes = [
      { Destination = "0.0.0.0/0"; Gateway = "10.2.0.1"; Table = 51821; GatewayOnLink = true; }
    ];
    networkConfig = {
      IPMasquerade = "ipv4";
      DNS = [ "10.2.0.1" ];
      DNSDefaultRoute = true;
    };
  };
  
  environment.systemPackages = [ pkgs.libnatpmp ];
  systemd.tmpfiles.rules = [
    "d /var/lib/transmission/natpmp 0750 transmission transmission - -"
  ];
  
  # Handle port forwarding
  systemd.services.transmission-natpmp = {
    description = "Refresh NAT-PMP mappings for Transmission (Proton)";
    # Make required tools available on PATH inside the unit
    path = with pkgs; [
      libnatpmp
      coreutils
      gawk
      transmission_4
    ];

    # Start only via the timer
    wantedBy = [ ];

    serviceConfig = {
      Type = "oneshot";
      User = "transmission";
      Group = "transmission";         # adjust if needed
      RuntimeDirectory = "natpmp";
      RuntimeDirectoryMode = "0755";
      # Optional: tighter sandboxing
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/transmission/natpmp" ];
    };

    script = ''
      set -euo pipefail

      run_dir="/var/lib/transmission/natpmp"
      port_file="$run_dir/natpmp-port"
      env_file="$run_dir/natpmp.env"
      gateway="10.2.0.1"

      date

      # Keep UDP mapping (harmless), extract TCP port for publishing
      out_udp="$(natpmpc -a ${toString transmission.torrentPort} 0 udp 60 -g "$gateway" 2>&1 || true)"
      out_tcp="$(natpmpc -a ${toString transmission.torrentPort} 0 tcp 60 -g "$gateway" 2>&1 || true)"

      echo "$out_udp"
      echo "$out_tcp"

      # Look for any line containing "public" and "port" and capture the number after "port"
      port="$(printf '%s\n%s\n' "$out_udp" "$out_tcp" \
        | grep -i 'public.*port' \
        | awk '{ for (i=1;i<=NF;i++) if ($i=="port") { print $(i+1); exit } }')"

      if [ -z "${port:-}" ]; then
        echo "No public port found in natpmpc output" >&2
        exit 1
      fi
      
      echo "Using mapped public port: $port"
      printf '%s\n' "$port" > "$port_file"
      printf 'NATPMP_PUBLIC_PORT=%s\n' "$port" > "$env_file"
      chmod 0644 "$port_file" "$env_file"
      
      remote="${transmission.rpcBindIPv4}:${toString transmission.rpcPort}"
      if [ -n "${toString transmission.rpcReqAuth}" ]; then
        transmission-remote "$remote" -n "" --port "$port" #TODO: Fix later
      else
        transmission-remote "$remote" --port "$port"
      fi
    '';
  };

  systemd.timers.transmission-natpmp = {
    description = "Run NAT-PMP refresh every 45 seconds";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "45s";
      AccuracySec = "1s";
      Unit = "transmission-natpmp.service";
    };
  };
  
  boot.kernel.sysctl = {
    "net.ipv4.conf.wg-proton.rp_filter" = 0;  # off is safest with PBR
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    # ~64 MiB background, ~256 MiB hard cap
    "vm.dirty_background_bytes" = 67108864;
    "vm.dirty_bytes"            = 268435456;
    "vm.dirty_expire_centisecs" = 3000;  # 30s until dirty data is old
    "vm.dirty_writeback_centisecs" = 500; # 5s writeback period
  };
  
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="vd[a-z]", ATTR{queue/scheduler}="mq-deadline"
  '';
}
