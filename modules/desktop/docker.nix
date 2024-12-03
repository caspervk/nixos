{...}: {
  # Docker is a utility to pack, ship and run any application as a lightweight
  # container.
  # https://wiki.nixos.org/wiki/Docker

  virtualisation.docker = {
    enable = true;
    # Automatically `docker system prune` weekly
    autoPrune.enable = true;
  };

  # Being a member of the docker group is effectively equivalent to being root,
  # but without the annoyance of having to type your sudo password all the time.
  users.groups.docker.members = ["caspervk"];

  # Persist docker volumes
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/docker";
        user = "root";
        group = "root";
        mode = "0700";
      }
    ];
  };
}
