{...}: {
  # Syncthing is a continuous file synchronization program. It synchronizes
  # files between two or more computers in real time. It's basically a
  # self-hosted Dropbox for Linux users, but without FTP, curlftpfs, and SVN.
  # https://wiki.nixos.org/wiki/Syncthing
  #
  # Access server's WebUI from desktop:
  # > ssh -L 9999:localhost:8384 sigma
  services.syncthing = {
    # NOTE: syncthing is enabled and further configured in
    # hosts/*/syncthing.nix.
    openDefaultPorts = true;
    user = "caspervk";
    dataDir = "/home/caspervk";
    settings = {
      options = {
        # Don't submit anonymous usage data
        urAccepted = -1;
      };
    };
  };
}
