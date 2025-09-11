{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) mkOption mkEnableOption types mkIf mapAttrsToList attrsets;
  secretsRepo = sources.secrets;
  cfg = config.cauldron.host.network.wireguard;

  mkSecretName = name: "wg-${name}-key";
in {
  config = mkIf cfg.enable (
    let
      tunnelsList = attrsets.mapAttrsToList (name: t: {
        name = name;
        iface = t.interfaceName;
        secretName = mkSecretName name;
        addresses = t.addresses;
        routes = t.routes;

        # Decide how to handle the privateKey
        keySource =
          if t.privateKey.kind == "file" then {
            kind = "file";
            file = t.privateKey.path;
          } else {
            kind = "sops";
            sopsFile = "${secretsRepo}/trove/${t.privateKey.path}";
          };
      }) cfg.tunnels;
      
      netdevs = builtins.listToAttrs (map (t: {
        name = t.iface;
        value = {
          netdevConfig = {
            Kind = "wireguard";
            Name = t.iface;
          };
          wireguardConfig = {
            PrivateKeyFile =
              if t.keySource.kind == "file" then
                t.keySource.file
              else
                "/run/secrets/${t.secretName}";
          };
        };
      }) tunnelsList);
      
      networks = builtins.listToAttrs (map (t: {
        name = t.iface;
        value = {
          matchConfig.Name = t.iface;
          addresses = map (addr: { Address = addr; }) t.addresses;
          routes    = map (rt:   { Route = rt;   }) t.routes;
        };
      }) tunnelsList);
      
      secrets = builtins.listToAttrs (map (t:
        if t.keySource.kind == "sops" then {
          name = t.secretName;
          value = {
            sopsFile = t.keySource.sopsFile;
            format   = "binary";
            owner = "systemd-network";
            group = "systemd-network";
            mode  = "0400";
          };
        } else null
      ) tunnelsList);
    in {
      # Only sops-based keys go into secrets
      sops.secrets = lib.filterAttrs (_: v: v != null) secrets;

      systemd.network.netdevs  = netdevs;
      systemd.network.networks = networks;
    }
  );
}
