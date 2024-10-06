{
  config,
  pkgs,
  ...
}: {
  # Knot Resolver is a minimalistic implementation of a caching validating DNS
  # resolver. Modular architecture keeps the core tiny and efficient, and it
  # provides a state-machine like API for extensions.
  # https://knot-resolver.readthedocs.io/en/stable/index.html
  #
  # Test resolver:
  # > nix shell nixpkgs#knot-dns
  # > kdig -d @dns.caspervk.net example.com
  # > kdig -d +https @dns.caspervk.net example.com
  # > kdig -d +tls @dns.caspervk.net example.com
  #
  # Connect to control socket:
  # > nix shell nixpkgs#socat -c sudo socat readline UNIX-CONNECT:/run/knot-resolver/control/1
  # >> help()
  # >> cache.clear("example.com")
  # https://knot-resolver.readthedocs.io/en/stable/daemon-scripting.html
  services.kresd = {
    enable = true;
    # For maximum performance, there should be as many kresd processes as there
    # are available CPU threads.
    # https://knot-resolver.readthedocs.io/en/stable/systemd-multiinst.html
    instances = 2;
    extraConfig =
      # lua
      ''
        -- Explicitly listen to DNS/DoH/DoT on the external interface(s). This
        -- allows systemd-resolved to listen on localhost as on every other system.
        local ipv4 = "159.69.4.2"
        local ipv6 ="2a01:4f8:1c0c:70d1::1"
        net.listen(ipv4, 53, {kind = "dns"})
        net.listen(ipv6, 53, {kind = "dns"})
        net.listen(ipv4, 853, {kind = "tls"})
        net.listen(ipv6, 853, {kind = "tls"})
        net.listen(ipv4, 443, {kind = "doh2"})
        net.listen(ipv6, 443, {kind = "doh2"})
        -- TLS certificate for DoT and DoH
        -- https://knot-resolver.readthedocs.io/en/stable/daemon-bindings-net_tlssrv.html
        net.tls(
          "${config.security.acme.certs."caspervk.net".directory}/fullchain.pem",
          "${config.security.acme.certs."caspervk.net".directory}/key.pem"
        )
        -- Cache is stored in /var/cache/knot-resolver, which is mounted as
        -- tmpfs. Allow using 75% of the partition for caching.
        -- https://knot-resolver.readthedocs.io/en/stable/daemon-bindings-cache.html
        cache.size = math.floor(cache.fssize() * 0.75)
        -- The predict module helps to keep the cache hot by prefetching
        -- records. Any time the resolver answers with records that are about to
        -- expire, they get refreshed.
        -- https://knot-resolver.readthedocs.io/en/stable/modules-predict.html
        modules.load("predict")
        -- Block spam and advertising domains
        -- https://knot-resolver.readthedocs.io/en/stable/modules-policy.html#response-policy-zones
        policy.add(
          policy.rpz(
            policy.ANSWER({ [kres.type.A] = {rdata=kres.str2ip("0.0.0.0"), ttl = 600} }),
            "${pkgs.runCommand "stevenblack-blocklist-rpz" {} ''grep '^0\.0\.0\.0' ${pkgs.stevenblack-blocklist}/hosts | awk '{print $2 " 600 IN CNAME .\n*." $2 " 600 IN CNAME ."}' > $out''}"
          )
        )
        -- Test domain to verify DNS server is being used
        policy.add(
          policy.domains(
            policy.ANSWER({ [kres.type.A] = {rdata = kres.str2ip("192.0.2.0"), ttl = 5} }),
            policy.todnames({"test.dns.caspervk.net"})
          )
        )
      '';
  };

  networking.firewall = {
    allowedTCPPorts = [443 853];
    allowedUDPPorts = [53];
  };
}
