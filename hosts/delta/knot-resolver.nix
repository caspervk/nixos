{
  config,
  inputs,
  pkgs,
  ...
}: {
  # Knot Resolver is an open-source implementation of a caching validating DNS
  # resolver.
  # https://www.knot-resolver.cz/documentation/latest/
  #
  # Test resolver:
  #
  #   nix shell nixpkgs#knot-dns
  #
  #   kdig -d @dns.caspervk.net example.com
  #   kdig -d +https @dns.caspervk.net example.com
  #   kdig -d +tls @dns.caspervk.net example.com
  #   kdig -d +quic @dns.caspervk.net example.com
  #
  #   kdig -d @159.69.4.2 example.com
  #   kdig -d +https @159.69.4.2 example.com
  #   kdig -d +tls @159.69.4.2 example.com
  #   kdig -d +quic @159.69.4.2 example.com
  #
  #   kdig -d @159.69.4.2 _dns.resolver.arpa SVCB
  #
  # Clear cache:
  #
  #   sudo kresctl cache clear example.com.
  #
  services.knot-resolver = {
    enable = true;
    settings = {
      network = {
        listen = [
          # Blocks spam and advertising domains
          {
            interface = ["159.69.4.2" "2a01:4f8:1c0c:70d1::1"];
            kind = "dns";
          }
          {
            interface = ["159.69.4.2" "2a01:4f8:1c0c:70d1::1"];
            kind = "doh2";
          }
          {
            interface = ["159.69.4.2" "2a01:4f8:1c0c:70d1::1"];
            kind = "dot";
          }
          {
            interface = ["159.69.4.2" "2a01:4f8:1c0c:70d1::1"];
            kind = "doq";
          }
          # Doesn't censor anything. This is primarily for the tor exit relay,
          # since not censoring anything is kind of the whole point of tor.
          {
            interface = ["2a01:4f8:1c0c:70d1::2"];
            kind = "dns";
          }
          {
            interface = ["2a01:4f8:1c0c:70d1::2"];
            kind = "doh2";
          }
          {
            interface = ["2a01:4f8:1c0c:70d1::2"];
            kind = "dot";
          }
          {
            interface = ["2a01:4f8:1c0c:70d1::2"];
            kind = "doq";
          }
        ];
        tls = {
          cert-file = "${config.security.acme.certs."dns.caspervk.net".directory}/fullchain.pem";
          key-file = "${config.security.acme.certs."dns.caspervk.net".directory}/key.pem";
        };
      };
      cache = {
        # The documentation recommends allocating 90% of the machine's free
        # memory for the resolver cache. The server has 4 GiB ram.
        size-max = "2048M";
        prefetch = {
          # Any time the resolver answers with records that are about to
          # expire, they get refreshed. Record is expiring if it has less than
          # 1% TTL (or less than 5s). That improves latency for records which
          # get frequently queried, relatively to their TTL.
          expiring = true;
        };
      };
      # TODO: https://www.knot-resolver.cz/documentation/latest/config-rate-limiting.html
      views = [
        {
          subnets = ["0.0.0.0/0"];
          dst-subnet = "159.69.4.2";
          tags = ["blocklist"];
        }
        {
          subnets = ["::/0"];
          dst-subnet = "2a01:4f8:1c0c:70d1::1";
          tags = ["blocklist"];
        }
      ];
      local-data = {
        # Discovery of Designated Resolvers (DDR) lets clients discover a DNS
        # resolver's encrypted DNS configuration, allowing it to move from
        # unencrypted to encrypted DNS. When only the resolver's IP address is
        # known, the client can query the resolver for SVCB records at the
        # special domain _dns.resolver.arpa., basically:
        #
        #   dig SVCB @159.69.4.2 _dns.resolver.arpa.
        #
        # https://www.rfc-editor.org/info/rfc9462/ (4. Discovery Using Resolver IP Addresses)
        rules = [
          {
            records = ''
              _dns.resolver.arpa. 3600 IN SVCB 1 dns.caspervk.net. alpn=doq ipv4hint=159.69.4.2 ipv6hint=2a01:4f8:1c0c:70d1::1
              _dns.resolver.arpa. 3600 IN SVCB 2 dns.caspervk.net. alpn=dot ipv4hint=159.69.4.2 ipv6hint=2a01:4f8:1c0c:70d1::1
              _dns.resolver.arpa. 3600 IN SVCB 3 dns.caspervk.net. alpn=h2 ipv4hint=159.69.4.2 ipv6hint=2a01:4f8:1c0c:70d1::1 dohpath=/dns-query{?dns}
            '';
            tags = ["blocklist"];
          }
        ];
        rpz = [
          {
            file = pkgs.runCommand "stevenblack-blocklist-rpz" {} ''
              ${pkgs.hosts-bl}/bin/Hosts-BL -i ${inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.stevenblack-blocklist}/hosts -f rpz -o $out
            '';
            tags = ["blocklist"];
          }
        ];
        addresses = {
          # Test domain to verify DNS server is being used
          "test.dns.caspervk.net" = "192.0.2.0";
        };
      };
    };
  };

  # Don't start until certificate is ready. Mirrors how modules with
  # useACMEHost do it (e.g. Caddy).
  systemd.services.knot-resolver = {
    after = ["acme-dns.caspervk.net.service"];
    wants = ["acme-dns.caspervk.net.service"];
  };

  networking.firewall = {
    allowedTCPPorts = [53 443 853];
    allowedUDPPorts = [53 853];
  };
}
