{...}: {
  # https://git.caspervk.net/caspervk/autosurfer

  virtualisation.oci-containers.containers = {
    autosurfer = {
      image = "quay.io/caspervk/autosurfer:latest";
      labels = {
        "io.containers.autoupdate" = "registry";
      };
      extraOptions = [
        "--cpus=1"
        "--memory=2g"
      ];
    };
  };
}
