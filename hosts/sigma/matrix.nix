{
  config,
  secrets,
  ...
}: {
  # https://element-hq.github.io/synapse/latest/
  # https://nixos.org/manual/nixos/stable/#module-services-matrix
  # https://wiki.nixos.org/wiki/Matrix
  # https://federationtester.matrix.org
  services.matrix-synapse = {
    enable = true;
    # https://element-hq.github.io/synapse/latest/usage/configuration/index.html
    settings = {
      # The server_name name appears at the end of usernames and room addresses
      # created on the server. It should NOT be a matrix-specific subdomain
      # such as matrix.example.com.
      # Caddy *does* however serve synapse on matrix.vkristensen.dk (rather
      # than vkristensen.dk directly). This is done through /.well-known/matrix delegation:
      # https://element-hq.github.io/synapse/latest/delegate.html.
      server_name = "vkristensen.dk";
      # The public-facing base URL that clients use to access this Homeserver.
      # This is the same URL a user might enter into the 'Custom Homeserver
      # URL' field on their client. If you use Synapse with a reverse proxy,
      # this should be the URL to reach Synapse via the proxy.
      public_baseurl = "https://matrix.vkristensen.dk";
      listeners = [
        {
          port = 8008;
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              # Enable client-server and server-server APIs
              names = ["client" "federation"];
            }
          ];
        }
      ];
      # Disable trusting signing keys from matrix.org (the default). If set to
      # the empty array, then Synapse will request the keys directly from the
      # server that owns the keys.
      # TODO: This is disabled (so we implicitly trust matrix.org) since,
      # apparently, the matrix protocol isn't distributed at all and nothing
      # works if you don't do this.
      # trusted_key_servers = [];
      # The public URIs of the TURN server to give to clients.
      # https://element-hq.github.io/synapse/latest/turn-howto.html
      turn_uris = ["turn:turn.matrix.org?transport=udp" "turn:turn.matrix.org?transport=tcp"];
      turn_shared_secret = "n0t4ctuAllymatr1Xd0TorgSshar3d5ecret4obvIousreAsons";
    };
  };

  services.postgresql = {
    ensureDatabases = [
      # matrix-synapse expects the database to have the options `LC_COLLATE`
      # and `LC_CTYPE` set to `C`, which basically instructs postgres to
      # ignore any locale-based preferences. Do this manually.
      # https://github.com/NixOS/nixpkgs/commit/8be61f7a36f403c15e1a242e129be7375aafaa85
      "matrix-synapse"
    ];
    ensureUsers = [
      # If the database user name equals the connecting system user name,
      # postgres by default will accept a passwordless connection via unix
      # domain socket. This makes it possible to run many postgres-backed
      # services without creating any database secrets at all.
      {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }
    ];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/matrix-synapse";
        user = "matrix-synapse";
        group = "matrix-synapse";
        mode = "0700";
      }
    ];
  };
}
