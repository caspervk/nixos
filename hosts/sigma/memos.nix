{...}: {
  # https://www.usememos.com/docs/install/self-hosting

  virtualisation.oci-containers.containers = {
    memos = {
      image = "docker.io/neosmemo/memos:stable";
      labels = {
        "io.containers.autoupdate" = "registry";
      };
      environment = {
        # https://github.com/usememos/memos/issues/2433#issuecomment-1797316081
        MEMOS_METRIC = "false";
      };
      ports = [
        # TODO: for some *very* weird reason, exposing the port does not work
        # if we use the same port on the host and inside the container. Why??
        "127.0.0.1:5231:5230"
      ];
      volumes = [
        "memos:/var/opt/memos"
      ];
    };
  };
}
