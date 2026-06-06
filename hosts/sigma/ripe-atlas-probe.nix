{...}: {
  # RIPE Atlas is a global network of probes that measure Internet connectivity
  # and reachability, providing an unprecedented understanding of the state of
  # the Internet in real time.
  # https://atlas.ripe.net/docs/howtos/software-probes

  # Register the probe at https://atlas.ripe.net/apply/swprobe/ with the public
  # key from `/etc/ripe-atlas/probe_key.pub`.

  # TODO: Use NixOS module when available
  # https://github.com/NixOS/nixpkgs/pull/462627
  # https://github.com/RIPE-NCC/ripe-atlas-software-probe/issues/143

  # https://github.com/Jamesits/docker-ripe-atlas/blob/master/contrib/docker-compose/docker-compose.yaml
  virtualisation.oci-containers.containers = {
    ripe-atlas-probe = {
      image = "docker.io/jamesits/ripe-atlas:latest-probe";
      labels = {
        "io.containers.autoupdate" = "registry";
      };
      volumes = [
        "ripe-atlas-probe:/etc/ripe-atlas"
        "ripe-atlas-probe:/run/ripe-atlas"
        "ripe-atlas-probe:/var/spool/ripe-atlas"
      ];
      capabilities = {
        # all = false;
        NET_RAW = true;
        KILL = true;
        SETUID = true;
        SETGID = true;
        CHOWN = true;
        FOWNER = true;
        DAC_OVERRIDE = true;
      };
      extraOptions = [
        "--network=host"
      ];
    };
  };

  # # Only allow access to wan0
  # systemd.services."podman-ripe-atlas-probe" = {
  #   serviceConfig = {
  #     RestrictNetworkInterfaces = "wan0";
  #   };
  # };
}
