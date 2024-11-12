{lib, ...}: {
  networking = {
    # Use dns.caspervk.net IPv6 address ::2 for uncensored DNS
    nameservers = lib.mkForce [
      "2a01:4f8:1c0c:70d1::2#dns.caspervk.net"
    ];
  };

  systemd.network = {
    networks."10-lan" = {
      matchConfig.Name = "enp0s18";
      address = [
        "185.231.102.51/24"
        "2a0c:5700:3133:650:b0ea:eeff:fedb:1f7b/64"
      ];
      routes = [
        {routeConfig = {Gateway = "185.231.102.1";};}
        # {
        #   routeConfig = {
        #     Gateway = "fe80::200:5eff:fe00:20c";
        #     GatewayOnLink = true;
        #   };
        # }
      ];
    };
  };
}
