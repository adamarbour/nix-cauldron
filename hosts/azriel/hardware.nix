{ ... }:
{
  services.udev.extraRules = ''
    KERNEL=="event*", SUBSYSTEM=="input", ATTRS{idVendor}=="2fe9", ATTRS{capabilities/abs}!="0", \
    ENV{ID_INPUT}="1", ENV{ID_INPUT_TOUCHSCREEN}="1", SYMLINK+="input/touchscreen0"
  '';
}
