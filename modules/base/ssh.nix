{ ... }: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
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
    "alpha".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0OmbNKuMGIOEUxqNDgUN9lz1LSw7xvZ6Tu/BkQyRoy";
    "delta".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0x9oImZjIhoPEwLlHVixIh7y1Kwn+SX17xffrdRzvv";
    "lambda".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEEd354UBnQi4xhjtJtKs4yVXuOkKY0svk+YHCm/pG46";
    "sigma".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2Qrh0tpR5YawiYvcPGC4OSnu4//ge1eVdiBDLrTbCx";
    "tor".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVPxvqwS2NMqqCGBkMmExzdBY5hGLegiOuqPJAOfdKk";
    "git.caspervk.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvPxSg6XN6znT1T4H0U1lzJBsGY7Uann+TBisWD3Drd";
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
