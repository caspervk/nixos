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
    # Extra features required for the lua cqueue library, which is required to
    # watch for changes in rpz blocklist.
    package = pkgs.knot-resolver.override {extraFeatures = true;};
    # For maximum performance there should be as many kresd processes as there
    # are available CPU threads.
    # https://knot-resolver.readthedocs.io/en/stable/systemd-multiinst.html
    instances = 2;
    extraConfig =
      # lua
      ''
        -- Explicitly only listen on external addresses to allow
        -- systemd-resolved to use localhost:53 as on every other system.
        local addresses = {
          -- Blocks spam and advertising domains
          ipv4_filtered = "159.69.4.2",
          ipv6_filtered = "2a01:4f8:1c0c:70d1::1",
          -- Don't censor anything. This is primarily for the tor exit relay,
          -- since not censoring anything is kind of the whole point of tor.
          ipv6_unfiltered = "2a01:4f8:1c0c:70d1::2",
        }
        for _, addr in pairs(addresses) do
          net.listen(addr, 53, {kind = "dns"})
          net.listen(addr, 853, {kind = "tls"})
          net.listen(addr, 443, {kind = "doh2"})
        end

        -- TLS certificate for DoT and DoH
        -- https://knot-resolver.readthedocs.io/en/stable/daemon-bindings-net_tlssrv.html
        net.tls(
          "${config.security.acme.certs."caspervk.net".directory}/fullchain.pem",
          "${config.security.acme.certs."caspervk.net".directory}/key.pem"
        )

        -- Beware that cache is shared by *all* requests. It is safe to refuse
        -- (policy.DENY) answer based on who asks the resolver, but trying to
        -- serve different data to different clients (policy.ANSWER) will result
        -- in unexpected behavior.
        -- https://knot-resolver.readthedocs.io/en/stable/modules-view.html
        -- https://knot-resolver.readthedocs.io/en/stable/modules-policy.html#response-policy-zones
        -- `true` means watch file for changes
        local blocklist = policy.rpz(policy.DENY, "/tmp/rpz-pro.txt", true)
        modules.load("view")
        -- `true` means apply view based on query destination rather than source
        view:addr(addresses.ipv4_filtered, blocklist, true)
        view:addr(addresses.ipv6_filtered, blocklist, true)

        -- Cache is stored in /var/cache/knot-resolver, which is persisted to
        -- disk. Choosing a cache size that can fit into RAM is important even
        -- if the cache is stored on disk. Otherwise, the extra I/O caused by
        -- disk access for missing pages can cause performance issues.
        -- The server has 4 GB ram.
        -- >> cache.stats()["usage_percent"]
        -- https://knot-resolver.readthedocs.io/en/stable/daemon-bindings-cache.html
        cache.size = 2048 * MB

        -- The predict module helps to keep the cache hot by prefetching records.
        -- It can utilize two independent mechanisms to select the records which
        -- should be refreshed: expiring records and prediction.
        -- The expiring records mechanism is always active and is not
        -- configurable. Any time the resolver answers with records that are about
        -- to expire, they get refreshed.
        -- https://knot-resolver.readthedocs.io/en/stable/modules-predict.html
        modules.load("predict")
        -- The prediction mechanism is prototype and not recommended for use in
        -- production. It is disabled by by configuring period=0.
        predict.config({period = 0})

        -- Test domain to verify DNS server is being used
        policy.add(
          policy.domains(
            policy.ANSWER({ [kres.type.A] = {rdata = kres.str2ip("192.0.2.0"), ttl = 5} }),
            policy.todnames({"test.dns.caspervk.net"})
          )
        )
      '';
  };

  # Ensure an empty blocklist exists so knot-resolver can start. We need
  # working DNS to fetch the blocklist, so we must start knot-resolver first.
  systemd.tmpfiles.rules = [
    "f /tmp/rpz-pro.txt 0644 knot-resolver knot-resolver"
  ];

  # Update the blocklist after when knot-resolver starts, and then once per day
  systemd.services.kresd-blocklist-updater = {
    after = ["network.target" "kresd@.service"];
    wants = ["kresd@.service"];
    # requiredBy = ["kresd@.service"];
    # before = ["kresd@.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.wget}/bin/wget --timestamping --output-document=/tmp/rpz-pro.txt https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/rpz/pro.txt";
      User = "knot-resolver";
      Group = "knot-resolver";
    };
  };
  systemd.timers.kresd-blocklist-updater = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "24h";
      Unit = "kresd-blocklist-updater.service";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [443 853];
    allowedUDPPorts = [53];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/cache/knot-resolver";
        user = "knot-resolver";
        group = "knot-resolver";
        mode = "0770";
      }
    ];
  };
}
