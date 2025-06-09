{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  systemd = {
    # Systemd OOMd
    # Fedora enables these options by default. See the 10-oomd-* files here:
    # https://src.fedoraproject.org/rpms/systemd/tree/acb90c49c42276b06375a66c73673ac3510255
    oomd = {
      enable = mkDefault true;
      enableRootSlice = true;
      enableUserSlices = true;
      enableSystemSlice = true;
      extraConfig = {
        "DefaultMemoryPressureDurationSec" = "20s";
      };
    };

    services.nix-daemon.serviceConfig.OOMScoreAdjust = mkDefault 350;
  };
}
