{lib, ...}: {
  networking = {
    # Use dns.caspervk.net IPv6 address ::2 for uncensored DNS
    nameservers = lib.mkForce [
      "2a01:4f8:1c0c:70d1::2#dns.caspervk.net"
    ];
  };

  systemd.network = {
    networks."10-lan" = {
      # IPv4 settings are from `sudo dhcpcd --test`.
      # IPv6 settings are from https://www.ssdvps.dk/knowledgebase/18/IPv6-Gateway.html.
      matchConfig.Name = "ens3";
      address = [
        "91.210.59.57/25"
        "2a12:bec4:11d3:de9f::1/64"
      ];
      routes = [
        {routeConfig = {Gateway = "91.210.59.1";};}
        {
          routeConfig = {
            Gateway = "2a12:bec4:11d3::1";
            GatewayOnLink = true;
          };
        }
      ];
    };
  };
}
