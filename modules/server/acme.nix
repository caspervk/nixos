{
  config,
  lib,
  secrets,
  ...
}:
# Only enable module if certificates are configured so we don't try to decrypt
# acme-lego-environment-file.age on servers that aren't allowed to.
lib.mkIf (config.security.acme.certs != {}) {
  # Instead of managing certificates in each individual service, NixOS supports
  # automatic certificate retrieval and renewal using
  # `security.acme.certs.<name>` through the ACME protocol.
  # https://nixos.wiki/wiki/ACME
  # https://nixos.org/manual/nixos/stable/index.html#module-security-acme
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "admin@caspervk.net";
      # The DNS challenge is passed by updating DNS records directly in the
      # zone on the authoritative DNS server (Knot).
      # https://go-acme.github.io/lego/dns/rfc2136/
      dnsProvider = "rfc2136";
      environmentFile = config.age.secrets.acme-lego-environment-file.path;
    };
  };

  # Persist certificates
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/acme";
        user = "acme";
        group = "acme";
        mode = "0755";
      }
    ];
  };

  age.secrets.acme-lego-environment-file = {
    file = "${secrets}/secrets/acme-lego-environment-file.age";
    mode = "400";
    owner = "root";
    group = "root";
  };

  # TODO
  # https://search.nixos.org/options?channel=23.11&show=services.caddy.virtualHosts.%3Cname%3E.useACMEHost&from=0&size=50&sort=relevance&type=packages&query=services.caddy
  # security.acme.certs."caspervk.net" = {
  #   domain = "*.caspervk.net";
  #   group = "users";
  #   reloadServices = [];
  # };
}
