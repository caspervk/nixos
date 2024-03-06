{...}: {
  security.sudo = {
    # Only allow members of the wheel group to execute sudo by setting the
    # executable's permissions accordingly. This prevents users that are not
    # members of wheel from exploiting vulnerabilities in sudo such as
    # CVE-2021-3156.
    execWheelOnly = true;

    # With great power comes great responsibility, we get it.. Also means we
    # don't have state in /var/db/sudo/lectured.
    extraConfig = ''
      Defaults lecture = never
    '';
  };
}
