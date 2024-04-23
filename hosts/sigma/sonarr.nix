{nixpkgs-unstable, ...}: {
  # Sonarr is an internet PVR for Usenet and Torrents.
  # https://sonarr.tv/
  #
  # NOTE: sonarr's config isn't managed by NixOS and its web interface REQUIRES
  # authentication even though we already have Caddy http basic auth. Just set
  # Sonarr to use http basic auth with the same username/password as Caddy and
  # everything will work. Other configuration:
  # * Media Management/Root Folder: /srv/torrents/tv/.
  # * Indexers: Add as needed.
  # * Download Clients: 'qBittorrent'. Host: 'localhost'. Category: 'tv'. Disable 'Remove Completed'.
  # * Metadata/Kodi: Enable.
  # * General/Analytics: Disable.
  # * UI: Fix retarded date formats.
  services.sonarr = {
    enable = true;
    # Unstable for sonarr v4. TODO: remove in NixOS 24.04
    package = nixpkgs-unstable.legacyPackages.x86_64-linux.sonarr;
    # Use the 'torrent' group to share files amongst downloaders, indexers etc.
    group = "torrent";
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/sonarr";
        user = "sonarr";
        group = "torrent";
        mode = "0750";
      }
    ];
  };
}
