{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.networking;
in {
  
  config = {
    networking.nameservers = [
      "9.9.9.9#dns.quad9.net"
      "1.1.1.1#cloudflare-dns.com"
    ];

    services.resolved = {
      enable = true;
      dnssec = "true";
      domains = [ "~." ];
      dnsovertls = "true";
      fallbackDns = [
        "9.9.9.9#dns.quad9.net"
        "1.1.1.1#cloudflare-dns.com"
        "2620:fe::9#dns.quad9.net"
        "2606:4700:4700::1111#cloudflare-dns.com"
      ];
      llmnr = "resolve";
    };
  };
}