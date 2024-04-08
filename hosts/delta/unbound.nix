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
    # Enable `unbound-control` to view stats stats etc.
    localControlSocketPath = "/run/unbound/unbound.ctl";
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
        # Use 0x20-encoded random bits in the query to foil spoof attempts.
        # This perturbs the lowercase and uppercase of query names sent to
        # authority servers and checks if the reply still has the correct
        # casing.
        use-caps-for-id = true;
        # Increase cache-hit ratio by serving old responses from the cache:
        # Before trying to resolve, Unbound will also consider expired cached
        # records as possible answers. If such a record is found it is
        # immediately returned to the client, Unbound then continues resolving
        # and hopefully updating the cached record. Used together with
        # prefetch, Unbound tries to update a cached record (after first
        # replying to the client) when the current TTL is within 10% of the
        # original TTL value. Although prefetching comes with a small penalty
        # of ~10% in traffic and load from the extra upstream queries, the
        # cache is kept up-to-date, at least for popular queries.
        #
        # Using serve-expired with prefetch is "highly recommended in order to
        # try and keep an updated cache". The following allows Unbound to:
        #  - prioritize (expired) cached replies,
        #  - keep the cache fairly up-to-date, and
        #  - in the likelihood that an expired record needs to be served (e.g.,
        #    rare query, issue with upstream resolving), make sure that the
        #    record is not older than the specified limit.
        # https://unbound.docs.nlnetlabs.nl/en/latest/topics/core/serve-stale.html
        prefetch = true;
        serve-expired = true;
        serve-expired-ttl = 14400; # 4 hours
        # Fetch the DNSKEYs earlier in the validation process, when a
        # DS record is encountered. This lowers the latency of requests.
        prefetch-key = true;
        # Increase the memory size of the cache. Use roughly twice as much
        # rrset cache memory as you use msg cache memory. Due to malloc
        # overhead, the total memory usage is likely to rise to double (or
        # 2.5x) the total cache memory that is entered into the configuration.
        # https://unbound.docs.nlnetlabs.nl/en/latest/topics/core/performance.html
        rrset-cache-size = "512m";
        msg-cache-size = "256m";
        # Testing domain
        local-zone = ["\"test.dns.caspervk.net.\" redirect"];
        local-data = ["\"test.dns.caspervk.net. A 192.0.2.0\""];
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
