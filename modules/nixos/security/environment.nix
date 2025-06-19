{
  environment.etc = {
    # Empty /etc/securetty to prevent root login on tty.
    securetty.text = ''
      # /etc/securetty: list of terminals on which root is allowed to login.
      # See securetty(5) and login(1).
    '';

    # Set machine-id to the Kicksecure machine-id, for privacy reasons.
    # /var/lib/dbus/machine-id doesn't exist on dbus enabled NixOS systems,
    # so we don't have to worry about that.
    machine-id.text = ''
      b08dfa6083e7567a1921a715000001fb
    '';
  };
}
