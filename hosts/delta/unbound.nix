{
  config,
  pkgs,
  ...
}: {
  # Unbound is a validating, recursive, caching DNS resolver. It is designed to
  # be fast and lean and incorporates modern features based on open standards.
  # https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html
  # > nix shell nixpkgs#knot-dns
  # > kdig -d @dns.caspervk.net example.com
  # > kdig -d +https @dns.caspervk.net example.com
  # > kdig -d +tls @dns.caspervk.net example.com
  services.unbound = {
    enable = true;
    # Don't mess with resolvconf
    resolveLocalQueries = false;
    settings = {
      server = {
        # Explicitly listen to DNS/DoH/DoT on the external interface(s). This
        # allows systemd-resolved to listen on localhost as on every other
        # system. Default is to listen to DNS on localhost only.
        interface = [
          "116.203.20.97@53"
          "116.203.20.97@443"
          "116.203.20.97@853"
          "2a01:4f8:c2c:6005::@53"
          "2a01:4f8:c2c:6005::@443"
          "2a01:4f8:c2c:6005::@853"
        ];
        # Allow access from all netblocks. Default is to allow localhost only.
        access-control = [
          "0.0.0.0/0 allow"
          "::0/0 allow"
        ];
        # Provide DNS-over-TLS or DNS-over-HTTPS service
        tls-service-key = "${config.security.acme.certs."caspervk.net".directory}/key.pem";
        tls-service-pem = "${config.security.acme.certs."caspervk.net".directory}/fullchain.pem";
        # Enable global ratelimiting of queries accepted per IP address. This
        # does not seem to impact TCP/DoH/DoT queries. Tested by adding +tcp,
        # +https, or +tls to the following (run it twice to warm up cache):
        # > seq 100 | xargs -n1 -I% dig @dns.caspervk.net %.example.net
        ip-ratelimit = 25;
        # Testing domain
        local-zone = [
          "\"test.dns.caspervk.net.\" redirect"
        ];
        local-data = [
          "\"test.dns.caspervk.net. A 192.0.2.0\""
        ];
        include = [
          (
            # The awk magic is from
            # https://deadc0de.re/articles/unbound-blocking-ads.html which is
            # linked from the StevenBlack GitHub.
            # https://nixos.org/manual/nixpkgs/stable/#trivial-builder-runCommand
            builtins.toString (pkgs.runCommand "stevenblack-blocklist-unbound" {} ''
              grep '^0\.0\.0\.0' ${pkgs.stevenblack-blocklist}/hosts | awk '{if (NR==1) {print "server:"} print "    local-zone: \""$2"\" redirect\n    local-data: \""$2" A 0.0.0.0\""}' > $out
            '')
          )
        ];
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [443 853];
    allowedUDPPorts = [53];
  };
}
