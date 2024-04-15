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
  # https://nixos.wiki/wiki/Caddy
  services.caddy = {
    enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [80 443];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/caddy";
        user = "caddy";
        group = "caddy";
        mode = "0755";
      }
    ];
  };
}
