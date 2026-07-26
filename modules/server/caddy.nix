{
  config,
  lib,
  ...
}:
# Virtual hosts are configured in each server's caddy.nix. This module
# configures shared auxiliary settings if any are configured.
lib.mkIf (config.services.caddy.virtualHosts != {}) {
  # Caddy is a powerful, enterprise-ready, open source web server with
  # automatic HTTPS written in Go.
  # https://wiki.nixos.org/wiki/Caddy
  services.caddy = {
    enable = true;
    openFirewall = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/www/html";
        mode = "0755";
        user = config.users.users.caddy.name;
        group = config.users.users.caddy.group;
      }
    ];
  };
}
