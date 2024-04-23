{...}: {
  # Jellyfin is a free and open-source media server and suite of multimedia
  # applications designed to organize, manage, and share digital media files to
  # networked devices.
  # https://jellyfin.org/
  # NOTE: Jellyfin config is not managed by NixOS. Here's how to set it up:
  # * Media Libraries:
  #   * Shows: /srv/torrents/tv/.
  #     * Disable all metadata download; will be gathered from Sonarr's .nfo's instead.
  #   * Movies: /srv/torrents/downloads/movies/.
  # * 'Allow remote connections to this server' should remain **enabled** even
  #   though we are using a reverse proxy.
  # * Install 'Kodi Sync Queue' under 'Admin/Plugins/Catalog'.
  services.jellyfin = {
    enable = true;
    # Use the 'torrent' group to share files amongst downloaders, indexers etc.
    group = "torrent";
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/jellyfin";
        user = "jellyfin";
        group = "torrent";
        mode = "0700";
      }
    ];
  };
}
