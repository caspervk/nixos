{lib, ...}: {
  # https://nixos.wiki/wiki/Networking
  # https://nixos.wiki/wiki/Systemd-networkd

  networking = {
    firewall = {
      # Allow some ports for ad-hoc use
      allowedTCPPorts = [1234 1337 8000 8080];
      allowedUDPPorts = [1234 1337 8000 8080];
      # Do not spam dmesg/journalctl with refused connections
      logRefusedConnections = false;
    };
    nameservers = ["127.0.0.1"]; # unbound
    search = ["caspervk.net"];
  };

  # TODO: these systemd networkd settings will be the default once
  # https://github.com/NixOS/nixpkgs/pull/202488 is merged.
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # Force-disable the systemd-resolved stub resolver, which is enabled
  # automatically in some cases, such as when enabling systemd-networkd.
  services.resolved.enable = lib.mkForce false;

  # Unbound provides DNS resolution to local applications on 127.0.0.1. It
  # enables caching and DNSSEC validation by default. We configure it to only,
  # and always, use dns.caspervk.net over TLS.
  # By the way, it's surprisingly hard to get the system to always follow the
  # custom DNS servers rather than the DHCP-provided ones. Check the traffic
  # with: sudo tcpdump -n --interface=any '(udp port 53) or (tcp port 853)'
  # https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = ["127.0.0.1"];
      };
      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "159.69.4.2#dns.caspervk.net"
            "2a01:4f8:1c0c:70d1::1#dns.caspervk.net"
          ];
          forward-tls-upstream = "yes";
        }
      ];
    };
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
