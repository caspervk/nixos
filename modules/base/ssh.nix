{...}: {
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.caspervk = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPB/qr63FB0ZqOe/iZGwIKNHD8a1Ud/mXVjQPmpIG7pM caspervk@omega"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII71DKQziktCkyMAmL25QKRK6nG2uJDkQXioIZp5JkMZ caspervk@zeta"
    ];
  };

  # ssh-keyscan -t ed25519 alpha
  programs.ssh.knownHosts = {
    "alpha".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOpQNEmmEe6jr7Mv37ozokvtTSd1I3SmUU1tpCSNTkc";
    "delta".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFe9RpnO1/QRU81kjtEsWN66xfP5Y/qf5EQZ6wdM/XCT";
    "sigma".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4Kvx/lcFRvl7KlxqqhrJ32h3FzuzyLA5BNB42+p92c";
    "tor".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOov/Qrjo7y86SO+qUdBC84NZdVsax/nksq9Vmmr1Uq";
    "git.caspervk.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4Kvx/lcFRvl7KlxqqhrJ32h3FzuzyLA5BNB42+p92c";
  };

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
