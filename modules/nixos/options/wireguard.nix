{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
  
  mkIfaceName  = name: "wg-${name}";
in {
  options.cauldron.host.network.wireguard = {
    enable = mkEnableOption "WireGuard tunnels via systemd-networkd + sops-nix";
    tunnels = mkOption {
      description = "WireGuard tunnels for this host.";
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          addresses = mkOption {
            type = types.listOf types.str;
            default = [ ];
            example = [ "10.10.10.11/24" ];
            description = "IP addresses (CIDR) to assign on the wg interface.";
          };
          routes = mkOption {
            type = types.listOf types.str;
            default = [ ];
            example = [ "10.10.10.0/24" ];
            description = "Routes to add via the wg interface.";
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
