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

  programs.ssh.knownHosts = {
    # Servers; ssh-keyscan -t ed25519 alpha
    "alpha".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOpQNEmmEe6jr7Mv37ozokvtTSd1I3SmUU1tpCSNTkc";
    "delta".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFe9RpnO1/QRU81kjtEsWN66xfP5Y/qf5EQZ6wdM/XCT";
    "git.caspervk.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4Kvx/lcFRvl7KlxqqhrJ32h3FzuzyLA5BNB42+p92c";
    "sigma".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4Kvx/lcFRvl7KlxqqhrJ32h3FzuzyLA5BNB42+p92c";
    "tor".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjmlrCSuBwpIUl4ic8Hq+CDlF4eXNVd1ejbY7Bdi9LC";

    # https://codeberg.org/Codeberg/org/src/branch/main/Imprint.md
    "codeberg.org".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";

    # https://api.github.com/meta
    "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

    # https://docs.gitlab.com/ee/user/gitlab_com/index.html#ssh-host-keys-fingerprints
    "gitlab.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";

    # https://man.sr.ht/git.sr.ht/
    "git.sr.ht".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
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
