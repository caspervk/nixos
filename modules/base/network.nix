{ ... }: {
  # https://nixos.wiki/wiki/Networking
  # https://nixos.wiki/wiki/Systemd-networkd

  networking = {
    firewall = {
      # Allow some ports for ad-hoc use
      allowedTCPPorts = [ 1234 1337 8000 8080 ];
      allowedUDPPorts = [ 1234 1337 8000 8080 ];
      # Do not spam dmesg/journalctl with refused connections
      logRefusedConnections = false;
    };
    nameservers = [ "127.0.0.53" ]; # resolved stub resolver
    search = [ "caspervk.net" ];
  };

  # TODO: these systemd networkd settings will be the default once
  # https://github.com/NixOS/nixpkgs/pull/202488 is merged.
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # systemd-resolved provides DNS resolution to local applications through
  # D-Bus, NSS, and a local stub resolver on 127.0.0.53. It implements caching
  # and DNSSEC validation. We configure it to only, and always, use
  # dns.caspervk.net over TLS. By the way, it's surprisingly hard to get the
  # system to always follow the custom DNS servers rather than the
  # DHCP-provided ones. Check the traffic with:
  # sudo tcpdump -n --interface=any '(udp port 53) or (tcp port 853)'
  # https://nixos.wiki/wiki/Encrypted_DNS
  # https://nixos.wiki/wiki/Systemd-resolved
  services.resolved = {
    enable = true;
    dnssec = "true";
    # Resolved falls back to DNS servers operated by American internet
    # surveillance and adtech companies by default. No thanks, I'd rather have
    # no DNS at all.
    fallbackDns = [ "159.69.4.2#dns.caspervk.net" "2a01:4f8:1c0c:70d1::1#dns.caspervk.net" ];
    extraConfig = ''
      DNS=159.69.4.2#dns.caspervk.net 2a01:4f8:1c0c:70d1::1#dns.caspervk.net
      DNSOverTLS=yes
    '';
  };

  # vnStat keeps a log of hourly, daily and monthly network traffic
  services.vnstat.enable = true;
  environment.persistence."/nix/persist" = {
    directories = [
      { directory = "/var/lib/vnstat"; user = "root"; group = "root"; mode = "0755"; }
    ];
  };
}
