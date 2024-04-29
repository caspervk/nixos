{...}: {
  # Podman can run rootless containers and be a drop-in replacement for Docker.
  # It is used for systemd services containers defined using
  # `virtualisation.oci-containers`.
  # https://wiki.nixos.org/wiki/Podman
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    # Automatically `podman system prune` weekly
    autoPrune.enable = true;
    # Required for containers under podman-compose to be able to talk to each
    # other.
    defaultNetwork.settings = {
      dns_enabled = true;
      ipv6_enabled = true;
    };
  };

  # Persist docker volumes
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/containers";
        user = "root";
        group = "root";
        mode = "0700";
      }
    ];
  };
}
