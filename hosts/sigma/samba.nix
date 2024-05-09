{
  config,
  secrets,
  ...
}: {
  # Samba provides file and print services for various Microsoft Windows
  # clients.
  # https://wiki.nixos.org/wiki/Samba
  #
  # The setup can be tested by:
  # > smbclient -L \\\\192.168.0.10
  # > smbclient \\\\192.168.0.21\\downloads -U caspervk
  #
  # Running .exe's and installing programs through a network drive doesn't
  # always work on Windows. The following tricks Windows by "mounting" the
  # network drive to a local drive letter (or something like that, who knows).
  # In cmd as administrator:
  # > net use \\192.168.0.10\downloads
  # > SUBST M: \\192.168.0.10\downloads
  # > dir M:
  # > M:\Programs\install.exe
  services.samba = {
    enable = true;
    # Disable discovery: don't reply to NetBIOS over IP name service requests
    # or participate in the browsing protocols which make up the Windows
    # “Network Neighborhood” view.
    enableNmbd = false;
    # Disable Samba’s winbindd, which provides a number of services to the Name
    # Service Switch capability found in most modern C libraries, to arbitrary
    # applications via PAM and ntlm_auth and to Samba itself.
    enableWinbindd = false;
    # https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
    extraConfig = ''
      # Only allow local access. This should also be enforced by the firewall.
      hosts deny ALL
      hosts allow = 192.168.0.0/16 127.0.0.1 localhost
      # Use user and group information from TDB database.
      # The age-encrypted database is created by setting in the config
      # > passdb backend = passdb backend = tdbsam:/tmp/samba-password-database
      # and running
      # > sudo pdbedit --create --user=caspervk
      passdb backend = tdbsam:${config.age.secrets.samba-password-database.path}
      # Allow Windows clients to run .exe's
      acl allow execute always = True
    '';
    shares = {
      downloads = {
        path = "/srv/torrents/downloads";
        # Use the 'torrent' group for access for all users connecting
        "force group" = "torrent";
      };
    };
  };

  age.secrets.samba-password-database = {
    file = "${secrets}/secrets/samba-password-database.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
