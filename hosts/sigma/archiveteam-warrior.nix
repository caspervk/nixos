{...}: {
  virtualisation.oci-containers.containers = {
    archiveteam-warrior = {
      # https://wiki.archiveteam.org/index.php?title=ArchiveTeam_Warrior#Advanced_usage_(container_only)
      image = "atdr.meo.ws/archiveteam/warrior-dockerfile:latest";
      labels = {
        "io.containers.autoupdate" = "registry";
      };
      environment = {
        # https://wiki.archiveteam.org/index.php/ArchiveTeam_Warrior/Docker_environment_variables
        DOWNLOADER = "x34xw9mjrntztxgr"; # nickname
        SELECTED_PROJECT = "auto";
        CONCURRENT_ITEMS = "6"; # max
      };
      ports = [
        # ssh -L 8001:localhost:8001 sigma
        "127.0.0.1:8001:8001"
      ];
    };
  };
}
