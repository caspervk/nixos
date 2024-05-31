{pkgs, ...}: {
  # https://nixos.org/manual/nixos/stable/#module-postgresql
  # https://wiki.nixos.org/wiki/PostgreSQL
  # > sudo -u postgres psql
  services.postgresql = {
    enable = true;
    # https://nixos.org/manual/nixos/stable/#module-services-postgres-upgrading
    package = pkgs.postgresql_16;
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
