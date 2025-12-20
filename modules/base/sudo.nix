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

  # TODO: replace sudo with run0 when this PR is released
  # https://github.com/polkit-org/polkit/issues/472
  # https://github.com/polkit-org/polkit/pull/533

  # TODO: rename this file

  # Polkit is used for controlling system-wide privileges. It provides an
  # organized way for non-privileged processes to communicate with privileged
  # ones. In contrast to systems such as sudo, it does not grant root
  # permission to an entire process, but rather allows a finer level of control
  # of centralized system policy.
  #
  # Polkit works by delimiting distinct actions, e.g. running GParted, and
  # delimiting users by group or by name, e.g. members of the wheel group. It
  # then defines how – if at all – those users are allowed those actions, e.g.
  # by identifying as members of the group by typing in their passwords.
  # https://wiki.nixos.org/wiki/Polkit
  # https://wiki.archlinux.org/title/Polkit
  # security.polkit.enable = true;
  # # Use run0 instead of sudo TODO: why?
  # security.sudo.enable = false;
  # programs.fish = {
  #   shellAliases = {
  #     "sudo" = "run0";
  #   };
  # };
}
