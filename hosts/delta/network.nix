{...}: {
  systemd.network = {
    # Main interface
    # https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Cloud
    networks."10-lan" = {
      name = "enp1s0";
      address = [
        "159.69.4.2/32"
        "2a01:4f8:1c0c:70d1::1/64"
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
