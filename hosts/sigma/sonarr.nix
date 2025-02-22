{...}: {
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
    # Use the 'torrent' group to share files amongst downloaders, indexers etc.
    group = "torrent";
  };

  # https://github.com/NixOS/nixpkgs/issues/360592
  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];

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
