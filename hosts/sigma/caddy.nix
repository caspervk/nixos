{
  config,
  inputs,
  ...
}: {
  services.caddy = {
    # The 'caspervk.net' ACME wildcard certificate is used whenever possible to
    # avoid leaking domains to the certificate transparency logs.
    virtualHosts = {
      "files.caspervk.net" = {
        useACMEHost = "caspervk.net";
        extraConfig = ''
          root * /var/www/html/files.caspervk.net
          # File browser
          handle /share* {
            file_server browse
          }
          # Direct download only
          handle {
            file_server
          }
        '';
      };
      "deluge.caspervk.net" = {
        useACMEHost = "caspervk.net";
        extraConfig = ''
          root * /srv/torrents/downloads

          # File browser with authentication
          handle_path /downloads/* {
            import /run/secrets/caddy-auth-sigma
            file_server browse
          }

          # Direct download without authentication
          handle_path /download/* {
            file_server
          }

          # Deluge Web UI with authentication
          handle {
            import /run/secrets/caddy-auth-sigma
            reverse_proxy localhost:8112
          }
        '';
      };
      "git.caspervk.net" = {
        useACMEHost = "caspervk.net";
        extraConfig = ''
          # Meta's bot is spamming so much
          @bots {
            header User-Agent *facebook*
          }
          handle @bots {
            header Retry-After 2629800
            respond 429
          }
          reverse_proxy localhost:3000
        '';
      };
      "jellyfin.caspervk.net" = {
        useACMEHost = "caspervk.net";
        extraConfig = ''
          reverse_proxy localhost:8096
        '';
      };
      "memos.caspervk.net" = {
        useACMEHost = "caspervk.net";
        extraConfig = ''
          reverse_proxy localhost:5230
        '';
      };
      "ntfy.caspervk.net" = {
        useACMEHost = "caspervk.net";
        extraConfig = ''
          reverse_proxy localhost:2586
        '';
      };
      "sonarr.caspervk.net" = {
        useACMEHost = "caspervk.net";
        extraConfig = ''
          import /run/secrets/caddy-auth-sigma
          reverse_proxy localhost:8989
        '';
      };
      "sudomail.org" = {
        useACMEHost = "sudomail.org";
        extraConfig = ''
          root * /var/www/html/sudomail.org
          file_server
          try_files {path}.html {path}
        '';
      };
      "vkristensen.dk" = {
        useACMEHost = "vkristensen.dk";
        extraConfig = ''
          # https://element-hq.github.io/synapse/latest/delegate.html
          header /.well-known/matrix/* Content-Type application/json
          header /.well-known/matrix/* Access-Control-Allow-Origin *
          respond /.well-known/matrix/server `{"m.server": "matrix.vkristensen.dk:443"}`
          respond /.well-known/matrix/client `{"m.homeserver": {"base_url": "https://matrix.vkristensen.dk"}, "org.matrix.msc3575.proxy": {"url": "https://matrix.vkristensen.dk"}}`
        '';
      };
      # https://element-hq.github.io/synapse/latest/reverse_proxy.html
      # Endpoints for administering the Synapse instance are placed under
      # /_synapse/admin. These require authentication through an access token
      # of an admin user. However as access to these endpoints grants the
      # caller a lot of power, exposing them is not recommended.
      "matrix.vkristensen.dk" = {
        useACMEHost = "vkristensen.dk";
        extraConfig = ''
          # sliding sync proxy
          reverse_proxy /_matrix/client/unstable/org.matrix.msc3575/sync localhost:8009
          # synapse
          reverse_proxy /_matrix/* localhost:8008
          reverse_proxy /_synapse/client/* localhost:8008
        '';
      };
    };
  };

  # Add caddy to the 'torrent' group to allow viewing downloads
  users.groups.torrent.members = ["caddy"];

  sops.secrets.caddy-auth-sigma = {
    sopsFile = "${inputs.secrets}/secrets/caddy-auth-sigma.enc";
    mode = "0400";
    owner = config.users.users.caddy.name;
    group = config.users.users.caddy.group;
  };
}
