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

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
