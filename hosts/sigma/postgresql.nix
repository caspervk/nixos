{pkgs, ...}: {
  # https://nixos.org/manual/nixos/stable/#module-postgresql
  # https://wiki.nixos.org/wiki/PostgreSQL
  # > sudo -u postgres psql
  services.postgresql = {
    enable = true;
    # https://nixos.org/manual/nixos/stable/#module-services-postgres-upgrading
    package = pkgs.postgresql_16;
    ensureDatabases = [
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
    initialScript = pkgs.writeText "init.sql" ''
      # https://github.com/NixOS/nixpkgs/commit/8be61f7a36f403c15e1a242e129be7375aafaa85
      CREATE DATABASE "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };

  services.postgresqlBackup = {
    enable = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/postgresql";
        user = "postgres";
        group = "postgres";
        mode = "0750";
      }
      {
        directory = "/var/backup/postgresql";
        user = "postgres";
        group = "root";
        mode = "0700";
      }
    ];
  };
}
