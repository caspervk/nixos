{ config, ... }: {
  systemd.network = {
    # Main interface
    networks."10-lan" = {
      name = "enp1s0";
      networkConfig.DHCP = "ipv4";
      address = [
        "2a01:4f8:c2c:71c0::/64"
      ];
      routes = [
        { routeConfig = { Gateway = "fe80::1"; }; }
      ];
    };

    # The following routes traffic destined for 49.13.33.75 (floating IP) to
    # sigma through wireguard. This allows the server to have a public address
    # even though it is behind NAT.
    netdevs."50-wg-sigma-public" = {
      netdevConfig = {
        Name = "wg-sigma-public";
        Kind = "wireguard";
      };
      wireguardConfig = {
        ListenPort = 51820;
        PrivateKeyFile = config.age.secrets.wireguard-private-key-file-alpha.path;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "sigmaH/DKSU8KWyrPtucYmS2ewUvDvCNLxd/qYEo0n0=";
            PresharedKeyFile = config.age.secrets.wireguard-preshared-key-file.path;
            # Add to the main routing table that traffic for the address should
            # be sent to sigma.
            AllowedIPs = [ "49.13.33.75/32" ];
            RouteTable = "main";
          };
        }
      ];
    };
    networks."wg-sigma-public" = {
      name = "wg-sigma-public";
    };
  };

  # Enable forwarding of packets
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.all.forwarding" = true;
  };

  networking = {
    firewall.allowedUDPPorts = [ 51820 ];
  };

  age.secrets.wireguard-preshared-key-file = {
    file = ../../secrets/wireguard-preshared-key-file.age;
    mode = "640";
    owner = "root";
    group = "systemd-network";
  };

  age.secrets.wireguard-private-key-file-alpha = {
    file = ../../secrets/wireguard-private-key-file-alpha.age;
    mode = "640";
    owner = "root";
    group = "systemd-network";
  };
}
