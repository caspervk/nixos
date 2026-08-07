{...}: {
  security.acme.certs = {
    "dns.caspervk.net" = {
      extraDomainNames = [
        "159.69.4.2"
        "2a01:4f8:1c0c:70d1::1"
        "2a01:4f8:1c0c:70d1::2"
      ];
      # IP address certificates must be shortlived and use the http-01 or
      # tls-alpn-01 challenge type.
      # https://letsencrypt.org/2026/01/15/6day-and-ip-general-availability
      profile = "shortlived";
      dnsProvider = null;
      listenHTTP = ":80";
      reloadServices = [
        "knot-resolver.service"
      ];
    };
  };
  users.groups.acme.members = [
    "knot-resolver"
  ];

  networking.firewall.allowedTCPPorts = [80];
}
