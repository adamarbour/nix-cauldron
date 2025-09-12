{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  
  mkIfaceName  = name: "wg-${name}";
in {
  options.cauldron.registry.wireguard = {
    tunnels = mkOption {
      type = types.attrsOf (types.attrsOf (types.submodule {
        options = {
          publicKey = mkOption { type = types.str; };
          addresses = mkOption { type = types.listOf types.str; default = []; };
          endpoint  = mkOption { type = types.nullOr types.str; default = null; }; # host or IP (no port)
          listenPort = mkOption { type = types.nullOr types.port; default = null; };
          extraAllowedIPs = mkOption { type = types.listOf types.str; default = []; };
          # Optional future fields:
          persistentKeepalive = mkOption { type = types.nullOr types.int; default = null; };
          # presharedKey: via sops/file (not shown here, easy to add)
        };
      }));
      default = {};
      description = "Per-tunnel registry keyed by tunnel → hostname → peer spec.";
    };
    defaults = mkOption {
      type = types.attrsOf (types.attrsOf types.anything);
      default = {};
      example = { "wg-cloud" = { mtu = 1380; }; };
      description = "Per-tunnel defaults (e.g., mtu) applied on every host in that tunnel.";
    };
  };

  options.cauldron.host.network.wireguard = {
    restartOnChange = mkOption {
      type = types.bool;
      default = true;
      description = ''
        When true, restart systemd-networkd whenever the generated
        /etc/systemd/network payload or any sops-managed WG key changes.
      '';
    };
    forceRestartOnSwitch = mkOption {
      type = types.bool;
      default = false;
      description = "Force a try-restart of systemd-networkd on every nixos-rebuild switch.";
    };
    tunnels = mkOption {
      description = "WireGuard tunnels for this host.";
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          enableIPForward = mkOption { type = types.bool; default = false; };
          masquerade = mkOption {
            type = types.nullOr (types.enum [ "both" "ipv4" "ipv6" ]);
            default = null;
            description = "Enable NAT (IPMasquerade) on this wg interface; choose yes/ipv4/ipv6.";
          };
          rpFilterMode = mkOption {
            type = types.enum [ "inherit" "loose" "strict" "off" ];
            default = "inherit";
            description = "Reverse-path filtering mode for this WireGuard iface.";
          };
          addresses = mkOption {
            type = types.listOf types.str;
            default = [ ];
            example = [ "10.10.10.11/24" ];
            description = "IP addresses (CIDR) to assign on the wg interface.";
          };
          routes = mkOption {
            # Pass through arbitrary [Route] keys/values for systemd-networkd
            type = lib.types.listOf (lib.types.attrsOf (lib.types.oneOf [
              lib.types.str lib.types.int lib.types.bool
            ]));
            default = [ ];
            example = [
              { Destination = "172.31.7.0/24"; Gateway = "172.31.7.1"; Metric = 100; }
              { Destination = "10.10.20.0/24"; Table = 123; }
            ];
            description = "List of systemd-networkd [Route] option sets.";
          };
          privateKey = mkOption {
            type = types.submodule {
              options = {
                kind = mkOption {
                  type = types.enum [ "sops" "file" ];
                  description = "Where the private key comes from: sops (relative path) or file (absolute path).";
                };
                path = mkOption {
                  type = types.str;
                  description = ''
                    If kind = "sops", path is relative to `secretsRepo`.  
                    If kind = "file", path must be absolute.
                  '';
                };
              };
            };
            description = "WireGuard private key source (sops-backed).";
          };
          # Optional, only needed if this host accepts inbound handshakes for the tunnel.
          listenPort = mkOption {
            type = types.nullOr types.port;
            default = null;
            example = 51820;
            description = "UDP port the interface listens on. If null, no explicit ListenPort is set.";
          };
          # When true and listenPort is set, open that UDP port in the firewall.
          openFirewall = mkOption {
            type = types.bool;
            default = false;
            description = "If true, add listenPort to networking.firewall.allowedUDPPorts.";
          };
          interfaceName = mkOption {
            type = types.str;
            default = mkIfaceName name;
            description = "Name of the created WireGuard interface.";
          };
        };
      }));
      default = { };
    };
  };
}
