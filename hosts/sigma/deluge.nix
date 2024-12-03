{
  lib,
  pkgs,
  secrets,
  ...
}: {
  # Deluge BitTorrent Client is a free and open-source, cross-platform
  # BitTorrent client written in Python.
  # https://www.deluge-torrent.org/
  services.deluge = {
    enable = true;
    # Use the 'torrent' group to share files amongst downloaders, indexers etc.
    group = "torrent";
    web.enable = true;
    # Config defaults:
    # https://git.deluge-torrent.org/deluge/tree/deluge/core/preferencesmanager.py#n41
    declarative = true;
    config = {
      download_location = "/srv/torrents/downloads/";
      # use the dedicated network interface and port
      listen_interface = secrets.hosts.sigma.sigma-p2p-ip-address;
      outgoing_interface = "wg-sigma-p2p";
      random_port = false;
      listen_ports = [60881];
      # no limits
      max_connections_global = -1;
      max_upload_slots_global = -1;
      max_half_open_connections = -1;
      max_connections_per_second = -1;
      max_active_seeding = -1;
      max_active_downloading = -1;
      max_active_limit = -1;
      # caching
      cache_size = 65536; # 65536 x 16KiB = 1GiB
      # enable label plugin, primarily for sonarr
      enabled_plugins = ["Label"];
    };
    # authfile is required with declarative=true; allow access from webui
    authFile = pkgs.writeTextFile {
      name = "deluge-auth";
      text = ''
        localclient::10
      '';
    };
  };

  # Only allow deluged internet access through wg-sigma-p2p. Note that this
  # does not tell it to use the correct routing table. For proper internet
  # access, the correct routing table is also configured by routingPolicyRules
  # in networking.nix.
  systemd.services.deluged = {
    serviceConfig = {
      RestrictNetworkInterfaces = "lo wg-sigma-p2p";
    };
  };

  # Add caspervk user to the 'torrent' group to allow viewing downloads
  users.groups.torrent.members = ["caspervk"];

  environment.persistence."/nix/persist" = {
    directories = [
      # Deluge data directory. This is *NOT* where the downloads are saved
      {
        directory = "/var/lib/deluge";
        user = "deluge";
        group = "torrent";
        mode = "0770";
      }
      # Since Sonarr insists on using hardlinks to manage media files, its
      # media library must be on the same volume as Deluge stores its
      # downloads. Therefore, Deluge will save to /srv/torrents/downloads/ and
      # Sonarr will hardlink in /srv/torrents/tv/. Jellyfin reads from
      # /srv/torrents/downloads/movies/ and /srv/torrents/tv/.
      {
        directory = "/srv/torrents";
        user = "deluge";
        group = "torrent";
        mode = "0770";
      }
    ];
  };
}
