{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.networking;
in {
  
  config = {
    networking.timeServers = [
      "0.nixos.pool.ntp.org"
      "1.nixos.pool.ntp.org"
      "2.nixos.pool.ntp.org"
      "3.nixos.pool.ntp.org"
    ];

    services.timesyncd = {
      enable = true;
      servers = [
        "tick.usno.navy.mil"
        "tock.usno.navy.mil"
        "ntp2.usno.navy.mi"
      ];
    };
  };
}