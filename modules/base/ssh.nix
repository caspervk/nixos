{ ... }: {
  services.openssh = {
    enable = true;
    # Security by obscurity? Nah, but it certainly reduces the logs volume.
    # Also, port 222 still requires root to bind.
    ports = [ 222 ];
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

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
