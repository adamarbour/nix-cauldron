{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkIf mkOption mkEnableOption mapAttrsToList;
  cfg = config.cauldron.network.innernet;
  
  innernet-server-db-path = "/var/lib/innernet-server";
  innernet-server-etc-path = "/etc/innernet-server";
  innernet-client-etc-path = "/etc/innernet";
  
  clientCfgs = mapAttrsToList (_: v: v) cfg.client;
  serverCfgs = mapAttrsToList (_: v: v) cfg.server;
  
  enabledFilter = builtins.filter (builtins.getAttr "enable");
  
  enabledClientCfgs = enabledFilter clientCfgs;
  enabledServerCfgs = enabledFilter serverCfgs;
  numEnabledCfgs = builtins.length (enabledClientCfgs ++ enabledServerCfgs);
  
  addNetwork = { networkName, cidr, externalEndpoint, listenPort, publicKey, privateKeyFile, ... }:
    pkgs.writeShellScript "add-network-${networkName}" ''
      rm -f ${innernet-server-etc-path}/${networkName}.conf ${innernet-server-db-path}/${networkName}.db
      ${cfg.package}/bin/innernet-server new \
        --network-name "${networkName}" \
        --network-cidr "${cidr}" \
        --external-endpoint "${externalEndpoint}" \
        --listen-port ${toString listenPort} >/dev/null
      PKEY="$(cat ${privateKeyFile})"
      export PKEY
      sed -i "s|private-key =.*|private-key = \"$PKEY\"|g" ${innernet-server-etc-path}/${networkName}.conf
      cat<<SQL | ${pkgs.sqlite}/bin/sqlite3 ${innernet-server-db-path}/${networkName}.db
        UPDATE peers
        SET public_key = '${publicKey}'
        WHERE name = 'innernet-server';
      SQL
    '';
    
  addCidr = { networkName, name, cidr, parent, ... }:
    pkgs.writeShellScript "add-cidr-${name}" ''
      ${cfg.package}/bin/innernet-server add-cidr \
        --name "${name}" \
        --cidr "${cidr}" \
        --parent "${parent} \
        --yes ${networkName} >/dev/null
    '';
    
  addPeer = { networkName, name, ip, cidr, publicKey, isAdmin ? false, ... }:
    pkgs.writeShellScript "add-peer-${name}" ''
      trap 'rm -f /tmp/${name}.toml' EXIT
      ${cfg.package}/bin/innernet-server add-peer \
        --name "${name}" \
        --ip "${ip}" \
        --cidr "${cidr}" \
        --admin "${isAdmin}" \
        --invite-expires "0s" \
        --save-config /tmp/${name}.toml \
        --yes ${networkName} >/dev/null
      cat<<SQL | ${pkgs.sqlite}/bin/sqlite3 ${innernet-server-db-path}/${networkName}.db
        UPDATE peers
        SET is_redeemed = 1,
            public_key = '${publicKey}'
        WHERE name = '${name}';
      SQL
    '';
  
  cidrsModule = with lib.types;
    submodule ({name, ...}: {
      options = {
        name = mkOption {
          type = str;
          default = name;
          description = "The name of the cidr block";
          example = "humans";
        };
        cidr = mkOption {
          type = str;
          description = "The cidr block";
          example = "10.100.4.0/22";
        };
        parent = mkOption {
          type = str;
          description = "The name of the parent cidr block";
        };
      };
    });
    
  associationModule = with lib.types;
    submodule {
      options = {
        leftCidr = mkOption {
          type = cidrsModule;
          description = "A cidr to associate with another";
        };
        rightCidr = mkOption {
          type = cidrsModule;
          description = "A cidr to associate with another";
        };
      };
    };
    
  peersModule = with lib.types;
    submodule ({name, ...}: {
      options = {
        name = mkOption {
          type = str;
          default = name;
          description = "The name of the peer";
          example = "hostname-1";
        };
        ip = mkOption {
          type = str;
          description = "The ip of the peer";
          example = "10.100.4.1";
        };
        cidr = mkOption {
          type = str;
          description = "The name of the cidr block this peer belongs to";
        };
        publicKey = mkOption {
          type = str;
          description = "The public key of the peer";
        };
        isAdmin = mkOption {
          type = bool;
          description = "Whether this pere is an admin";
          default = false;
          apply = v: if v then "true" else "false";
        };
      };
    });
in {
  options.cauldron.network.innernet = {
    package = mkOption {
      type = types.package;
      default = pkgs.innernet;
      defaultText = "pkgs.innernet";
      description = "The package to use for innernet.";
    };
    client = mkOption {
      default = {};
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          enable = mkEnableOption "innernet client daemon for ${name}";
          settings = mkOption {
            type = types.submodule {
              options = {
                interface = {
                  networkName = mkOption {
                    type = types.str;
                    default = name;
                    example = "innernet0";
                    description = "The name of the network we are connecting to.";
                  };
                  fetchInterval = mkOption {
                    type = types.int;
                    default = 25;
                    example = "25";
                    description = "How often to refresh peers from server.";
                  };
                  address = mkOption {
                    type = types.str;
                    example = "10.100.0.5/16";
                    description = "The address of this peer, the prefix should be that of the network (not the cidr this host is part of)";
                  };
                  privateKeyFile = mkOption {
                    type = types.path;
                    description = "The path to the private key file";
                    example = "/run/privat-key";
                  };
                };
                server = {
                  publicKey = mkOption {
                    type = types.str;
                    description = "The public key of the server";
                  };
                  externalEndpoint = mkOption {
                    type = types.str;
                    description = "The external endpoint of the server";
                    example = "1.2.3.4:51820";
                  };
                  internalEndpoint = mkOption {
                    type = types.str;
                    description = "The internal endpont of the server";
                    example = "10.100.0.1:51820";
                  };
                };
              };
            };
          };
        };
      }));
    };
    server = mkOption {
      default = {};
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          enable = mkEnableOption "innernet server daemon for ${name}";
          settings = mkOption {
            type = types.submodule {
              options = {
                networkName = mkOption {
                  type = types.str;
                  default = name;
                  description = "The name of the network";
                  example = "innernet0";
                };
                cidr = mkOption {
                  type = types.str;
                  description = "The network cidr of the root network";
                  example = "10.100.0.0/16";
                };
                privateKeyFile = mkOption {
                  type = types.path;
                  description = "The path to the private key file.";
                  example = "/run/server-private-key";
                };
                externalEndpoint = mkOption {
                  type = types.str;
                  description = "The external endpoint of the server";
                  example = "1.1.1.1:51820";
                };
                publicKey = mkOption {
                  type = types.str;
                  description = "The public key of the server";
                  example = "PUBKEY...";
                };
                listenPort = mkOption {
                  type = types.port;
                  description = "The server listen port.";
                  default = 51820;
                  example = 51820;
                };
                cidrs = mkOption {
                  type = types.attrsOf cidrsModule;
                  default = {};
                  description = "The cidrs of this network";
                };
                associations = mkOption {
                  type = types.listOf associationModule;
                  default = {};
                  description = "The associations between cidrs on this network";
                };
                peers = mkOption {
                  type = types.attrsOf peersModule;
                  default = {};
                  description = "The peers of this network";
                };
                openFirewall = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Whether to open relevant ports in the firewall automatically.";
                };
              };
            };
          };
        };
      }));
    };
  };
  
  config = mkIf (numEnabledCfgs > 0) {
    environment.systemPackages = [ cfg.package ];    
    networking.wireguard.enable = true;
    networking.firewall.allowedTCPPorts = map (server: server.settings.listenPort)
      (builtins.filter (server: server.settings.openFirewall) enabledServerCfgs);
    networking.firewall.allowedUDPPorts = map (server: server.settings.listenPort)
      (builtins.filter (server: server.settings.openFirewall) enabledServerCfgs);
      
    systemd.services = 
      # SERVERS
      (builtins.listToAttrs (map (server: {
        name = "innernet-server-${server.settings.networkName}";
        value = {
          after = [ "network-online.target" "nss-lookup.target" ];
          wantedBy = [ "multi-user.target" ];
          path = [ pkgs.iproute2 ];
          environment = { RUST_LOG = "info"; };
          serviceConfig = {
            Restart = "always";
            ExecStartPre = pkgs.writeShellScript "innernet-systemd-server-pre-${server.settings.networkName}" ''
              ${addNetwork server.settings}
              ${builtins.concatStringSep "\n" (map addCidr (mapAttrsToList (_: v: v // { inherit (server.settings) networkName; }) server.settings.cidrs))}
              ${builtins.concatStringSep "\n" (map addPeer (mapAttrsToList (_: v: v // { inherit (server.settings) networkName; }) server.settings.peers))}
            '';
            ExecStart = "${cfg.package}/bin/innernet-server serve ${server.settings.networkName}";
          };
        };
      }) enabledServerCfgs));
      
  };
}
