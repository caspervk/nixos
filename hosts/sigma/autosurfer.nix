{...}: {
  virtualisation.oci-containers.containers = {
    autosurfer = {
      # https://git.caspervk.net/caspervk/autosurfer
      image = "quay.io/caspervk/autosurfer:latest";
    };
  };
}
