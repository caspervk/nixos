{
  config,
  pkgs,
  ...
}: {
  # https://nixos.org/manual/nixos/stable/#module-postgresql
  # https://wiki.nixos.org/wiki/PostgreSQL
  # > sudo -u postgres psql
  services.postgresql = {
    enable = true;
    # https://nixos.org/manual/nixos/stable/#module-services-postgres-upgrading
    # https://wiki.nixos.org/wiki/PostgreSQL#Major_upgrades
    package = pkgs.postgresql_17;
  };

  services.postgresqlBackup = {
    enable = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/postgresql";
        user = config.users.users.postgres.name;
        group = config.users.users.postgres.group;
        mode = "0750";
      }
      {
        directory = "/var/backup/postgresql";
        user = config.users.users.postgres.name;
        group = config.users.groups.root.name;
        mode = "0700";
      }
    ];
  };
}
