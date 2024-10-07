{config, ...}: {
  # https://wiki.nixos.org/wiki/Networking
  # https://wiki.nixos.org/wiki/Systemd-networkd

  networking = {
    firewall = {
      # Allow some ports for ad-hoc use
      allowedTCPPorts = [1234 1337 8000 8080];
      allowedUDPPorts = [1234 1337 8000 8080];
      # Do not spam dmesg/journalctl with refused connections
      logRefusedConnections = false;
    };
    nameservers = [
      "159.69.4.2#dns.caspervk.net"
      "2a01:4f8:1c0c:70d1::1#dns.caspervk.net"
    ];
    search = ["caspervk.net"];
  };

  # TODO: these systemd networkd settings will be the default once
  # https://github.com/NixOS/nixpkgs/pull/264967 is merged.
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # The notion of "online" is a broken concept
  # https://github.com/nix-community/srvos/blob/main/nixos/common/networking.nix
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  # systemd-resolved provides DNS resolution to local applications through
  # D-Bus, NSS, and a local stub resolver on 127.0.0.53. It implements caching
  # and DNSSEC validation. We configure it to only, and always, use
  # dns.caspervk.net over TLS.
  # NOTE: It's surprisingly hard to get the system to always follow the custom
  # DNS servers rather than the DHCP-provided ones. Check the traffic with:
  # > sudo tcpdump -n --interface=any '(udp port 53) or (tcp port 853)'
  # or
  # > sudo resolvectl log-level debug
  # > sudo journalctl -fu systemd-resolved.service
  # https://wiki.nixos.org/wiki/Encrypted_DNS
  # https://wiki.nixos.org/wiki/Systemd-resolved
  services.resolved = {
    enable = true;
    dnsovertls = "true";
    # TODO: DNSSEC support in systemd-resolved is considered experimental and
    # incomplete. Upstream will validate for us anyway, and we trust it.
    # https://wiki.archlinux.org/title/systemd-resolved#DNSSEC
    dnssec = "false";
    # 'Domains' is used for two distinct purposes; first, any domains *not*
    # prefixed with '~' are used as search suffixes when resolving single-label
    # hostnames into FQDNs. The NixOS default is to set this to
    # `config.networking.search`, which we maintain. Second, domains prefixed
    # with '~' ("route-only domains") define a search path that preferably
    # directs DNS queries to this interface. The '~.' construct use the DNS
    # servers defined here preferably for the root (all) domain(s).
    # https://man.archlinux.org/man/resolved.conf.5
    domains = config.networking.search ++ ["~."];
    # Resolved falls back to DNS servers operated by American internet
    # surveillance and adtech companies by default. No thanks, I'd rather have
    # no DNS at all.
    fallbackDns = [];
  };

  # TCP BBR has significantly increased throughput and reduced latency. Note
  # that the IPv4 setting controls both IPv4 and IPv6.
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # vnStat keeps a log of hourly, daily and monthly network traffic
  services.vnstat.enable = true;
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/vnstat";
        user = "root";
        group = "root";
        mode = "0755";
      }
    ];
  };
}
