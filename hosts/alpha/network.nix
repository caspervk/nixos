{
  config,
  secrets,
  ...
}: {
  systemd.network = {
    # Main interface
    # https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Cloud
    networks."10-lan" = {
      name = "enp1s0";
      address = [
        "116.203.179.206/32"
        "2a01:4f8:c2c:71c0::/64"
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
      # Enable proxy ARP to answer ARP requests for the floating IP addresses,
      # intended for the wireguard peers, from Hetzner's router. Without this,
      # the router will not send traffic to us.
      networkConfig.IPv4ProxyARP = true;
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
            AllowedIPs = ["49.13.33.75/32"];
            RouteTable = "main";
          };
        }
      ];
    };
    networks."wg-sigma-public" = {
      name = "wg-sigma-public";
    };

    # The following routes traffic destined for the sigma-p2p address (floating
    # IP) to sigma through wireguard. This allows the server to have a public
    # address and help others sail the high seas even though it is behind NAT.
    netdevs."51-wg-sigma-p2p" = {
      netdevConfig = {
        Name = "wg-sigma-p2p";
        Kind = "wireguard";
      };
      wireguardConfig = {
        ListenPort = 51821;
        PrivateKeyFile = config.age.secrets.wireguard-private-key-file-alpha.path;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "sigmaH/DKSU8KWyrPtucYmS2ewUvDvCNLxd/qYEo0n0=";
            PresharedKeyFile = config.age.secrets.wireguard-preshared-key-file.path;
            AllowedIPs = ["${secrets.hosts.alpha.sigma-p2p-ip-address}/32"];
            RouteTable = "main";
          };
        }
      ];
    };
    networks."wg-sigma-p2p" = {
      name = "wg-sigma-p2p";
    };
  };

  # Enable forwarding of packets
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.all.forwarding" = true;
  };

  networking = {
    firewall.allowedUDPPorts = [51820 51821];
  };

  age.secrets.wireguard-preshared-key-file = {
    file = "${secrets}/secrets/wireguard-preshared-key-file.age";
    mode = "440";
    owner = "root";
    group = "systemd-network";
  };

  age.secrets.wireguard-private-key-file-alpha = {
    file = "${secrets}/secrets/wireguard-private-key-file-alpha.age";
    mode = "440";
    owner = "root";
    group = "systemd-network";
  };
}
