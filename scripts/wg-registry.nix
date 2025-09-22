{ nodes, lib, ... }:
let
  inherit (lib) foldlAttrs filterAttrs mapAttrs;
  
  # Pick only keys we want to publish for each peer
  keepPeerKeys = peer: let
    base = {
      publicKey = peer.publicKey or null;
      endpoint = peer.endpoint or null;
      listenPort = peer.listenPort or null;
      addresses = peer.addresses or [];
      extraAllowedIPs = peer.extraAllowedIPs or [];
    };
  in filterAttrs (_: v: v != null && v != []) base;
  
  # Turn nodes.<host>.config.cauldron.host.network.wireguard.tunnels into registry shape
  fromNode = hostName: hostCfg: let
    tunnels = hostCfg.config.cauldron.host.network.wireguard.tunnels or {};
  in mapAttrs (_tunnel: tCfg: keepPeerKeys tCfg) tunnels;
  
  # For all nodes, gather per-tunnel peers into "tunnels.<name>.<host> = peerData"
  foldPeers = foldlAttrs (acc: hostName: nodeCfg: let
    perHost = fromNode hostName nodeCfg;
  in foldlAttrs (acc2: tunnelName: peerData:
    acc2 // {
      ${tunnelName} = (acc2.${tunnelName} or {}) // { ${hostName} = peerData; };
    }) acc perHost) {};
    
  tunnels = foldPeers nodes;
in {
  tunnels = tunnels;
}
