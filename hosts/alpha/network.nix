{ ... }: {
  systemd.network.networks = {
    "10-lan" = {
      name = "enp1s0";
      networkConfig.DHCP = "ipv4";
      address = [
        "2a01:4f8:c2c:71c0::/64"
      ];
      routes = [
        { routeConfig = { Gateway = "fe80::1"; }; }
      ];
    };
  };
}
