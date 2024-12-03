{...}: {
  systemd.network = {
    # Main interface
    # https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud
    networks."10-lan" = {
      matchConfig.Name = "enp1s0";
      address = [
        # NOTE: Default outgoing address is the LAST address in the list
        "159.69.4.2/32"
        "2a01:4f8:1c0c:70d1::2/64"
        "2a01:4f8:1c0c:70d1::1/64"
      ];
      routes = [
        {Destination = "172.31.1.1";}
        {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
        }
        {Gateway = "fe80::1";}
      ];
    };
  };
}
