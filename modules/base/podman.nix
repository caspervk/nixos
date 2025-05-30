{
  lib,
  pkgs,
  ...
}: {
  # Podman can run rootless containers and be a drop-in replacement for Docker.
  # It is used for systemd services containers defined using
  # `virtualisation.oci-containers`.
  # https://wiki.nixos.org/wiki/Podman

  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings = {
      # DNS is required for containers under podman-compose to be able to talk
      # to each other.
      dns_enabled = true;
      ipv6_enabled = true;
    };
    # Automatically `podman system prune -f` weekly
    autoPrune.enable = true;
    # Create an alias mapping `docker` to `podman`. This does *not* enable the
    # docker-compatible socket (`virtualisation.podman.dockerSocket.enable`),
    # which would allow members of the `podman` group to gain root access.
    dockerCompat = true;
  };

  virtualisation.containers = {
    enable = true;
    containersConf.settings = {
      engine = {
        # `podman compose` is a thin wrapper around an external compose provider
        # such as `docker-compose` or `podman-compose.` This means that `podman
        # compose` is executing another tool that implements the compose
        # functionality but sets up the environment in a way to let the compose
        # provider communicate transparently with the local Podman socket.
        # https://docs.podman.io/en/stable/markdown/podman-compose.1.html
        # Redhat focuses more on making `docker-compose` work with Podman than
        # supporting `podman-compose` (and it looks better), so we use that.
        # https://github.com/containers/podman-compose/issues/276#issuecomment-809463088
        compose_providers = ["${pkgs.docker-compose}/bin/docker-compose"];
        # By default, `podman compose` will emit a warning saying that it
        # executes an external command.
        compose_warning_logs = false;
      };
      network = {
        # The default networking stack for rootless containers, pasta, doesn't
        # seem to work properly. Test using:
        # > podman run --rm -it --network=pasta quay.io/lib/debian:latest apt update
        # vs
        # > podman run --rm -it --network=slirp4netns quay.io/lib/debian:latest apt update
        default_rootless_network_cmd = "slirp4netns";
      };
    };
  };

  # Add default image mirrors. NixOS generates registries.conf in the
  # deprecated version 1 format so we overwrite the entire file.
  # https://github.com/containers/image/blob/main/docs/containers-registries.conf.5.md
  environment.etc."containers/registries.conf".text =
    lib.mkForce
    # toml
    ''
      # Unqualified images suck, but we'll do it for granddad
      unqualified-search-registries = ["docker.io"]

      # Use Quay mirror of docker.io/library ("Docker Official") images
      [[registry]]
      location = "docker.io/library"
      [[registry.mirror]]
      location = "quay.io/lib"

      # Use Google's Docker Hub mirror for everything else docker.io
      # https://cloud.google.com/artifact-registry/docs/pull-cached-dockerhub-images
      [[registry]]
      location = "docker.io"
      [[registry.mirror]]
      location = "mirror.gcr.io"
    '';

  # Use the (rootless) Podman user socket for compatibility with Docker-only
  # tools such as `dive`.
  # https://k3d.io/stable/usage/advanced/podman/#using-rootless-podman
  environment.sessionVariables = rec {
    DOCKER_HOST = "unix://${DOCKER_SOCK}";
    DOCKER_SOCK = "\${XDG_RUNTIME_DIR}/podman/podman.sock";
  };

  # Auto-update containers with the `io.containers.autoupdate` label.
  # https://docs.podman.io/en/latest/markdown/podman-auto-update.1.html
  systemd = {
    timers.podman-auto-update.enable = true;
    units."podman-auto-update.timer".wantedBy = ["timers.target"];
  };

  # Persist podman volumes
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
