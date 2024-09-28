{...}: {
  virtualisation.oci-containers.containers = {
    autosurfer = {
      # https://git.caspervk.net/caspervk/autosurfer
      image = "quay.io/caspervk/autosurfer:latest";
      extraOptions = [
        "--cpus=1"
        "--memory=2g"
      ];
    };
  };
}
