{...}: {
  systemd.network = {
    # Main interface
    # https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Cloud
    networks."10-lan" = {
      name = "enp1s0";
      address = [
        "116.203.20.97/32" # TODO
        "2a01:4f8:c2c:6005::/64" # TODO
      ];
      routes = [
        {routeConfig = {Destination = "172.31.1.1";};}
        {
          routeConfig = {
            Gateway = "172.31.1.1";
            GatewayOnLink = true;
          };
        }
        {routeConfig = {Gateway = "fe80::1";};}
      ];
    };
  };
}
