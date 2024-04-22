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
    web.enable = true;
    # https://git.deluge-torrent.org/deluge/tree/deluge/core/preferencesmanager.py#n41
    declarative = true;
    config = {
      # use dedicated interface
      listen_interface = secrets.sigma.sigma-p2p-ip-address;
      outgoing_interface = "wg-sigma-p2p";
      random_port = false;
      listen_ports = [60881];
      # encrypt everything
      enc_in_policy = 0;
      enc_out_policy = 0;
      enc_level = 1;
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
      # enable label plugin for sonarr
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

  # Add 'caddy' to the 'deluge' group to allow browsing files
  users.groups.deluge.members = ["caddy"];

  # Only allow deluged internet access through wg-sigma-p2p
  systemd.services.deluged = {
    serviceConfig = {
      RestrictNetworkInterfaces = "lo wg-sigma-p2p";
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/deluge";
        user = "deluge";
        group = "deluge";
        mode = "0770";
      }
    ];
  };
}
