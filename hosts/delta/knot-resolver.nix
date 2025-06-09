{
  config,
  dns-blocklist,
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
    # For maximum performance there should be as many kresd processes as there
    # are available CPU threads.
    # We double it to account for the SYSTEMD_INSTANCE scheme below.
    # https://knot-resolver.readthedocs.io/en/stable/systemd-multiinst.html
    instances = 4;
    extraConfig =
      # lua
      ''
        -- Explicitly only listen on external addresses to allow
        -- systemd-resolved to use localhost:53 as on every other system.
        local ipv4 = "159.69.4.2"
        local ipv6_1 = "2a01:4f8:1c0c:70d1::1"
        local ipv6_2 = "2a01:4f8:1c0c:70d1::2"
        -- We want to apply different query policies based on the listening
        -- address, but doing so is difficult. Instead, we define bind address
        -- and query policies together based on the systemd instance number.
        -- https://knot-resolver.readthedocs.io/en/stable/systemd-multiinst.html#instance-specific-configuration
        local systemd_instance = tonumber(os.getenv("SYSTEMD_INSTANCE"))
        if systemd_instance % 2 == 0 then
          -- IPv4 and IPv6-1: Block spam and advertising domains.
          net.listen(ipv4, 53, {kind = "dns"})
          net.listen(ipv6_1, 53, {kind = "dns"})
          net.listen(ipv4, 853, {kind = "tls"})
          net.listen(ipv6_1, 853, {kind = "tls"})
          net.listen(ipv4, 443, {kind = "doh2"})
          net.listen(ipv6_1, 443, {kind = "doh2"})
          -- https://knot-resolver.readthedocs.io/en/stable/modules-policy.html#response-policy-zones
          policy.add(
            policy.rpz(
              -- Beware that cache is shared by *all* requests. For example, it is
              -- safe to refuse (policy.DENY) answer based on who asks the resolver,
              -- but trying to serve different data to different clients (policy.ANSWER)
              -- will result in unexpected behavior.
              -- https://knot-resolver.readthedocs.io/en/stable/modules-view.html:
              policy.DENY,
              "${dns-blocklist}"
            )
          )
        else
          -- IPv6-2: Don't censor anything.
          -- This is primarily for the tor exit relay, since not censoring
          -- anything is kind of the whole point of tor.
          net.listen(ipv6_2, 53, {kind = "dns"})
          net.listen(ipv6_2, 853, {kind = "tls"})
          net.listen(ipv6_2, 443, {kind = "doh2"})
        end
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
