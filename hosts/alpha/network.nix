{
  config,
  secrets,
  ...
}: {
  systemd.network = {
    # Main interface
    # https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud
    networks."10-lan" = {
      matchConfig.Name = "enp1s0";
      address = [
        "116.203.179.206/32"
        "2a01:4f8:c2c:71c0::/64"
      ];
      routes = [
        {Destination = "172.31.1.1";}
        {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
        }
        {Gateway = "fe80::1";}
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
          PublicKey = "sigmaH/DKSU8KWyrPtucYmS2ewUvDvCNLxd/qYEo0n0=";
          PresharedKeyFile = config.age.secrets.wireguard-preshared-key-file.path;
          # Add to the main routing table that traffic for the address should
          # be sent to sigma.
          AllowedIPs = ["49.13.33.75/32"];
          RouteTable = "main";
        }
      ];
    };
    networks."50-wg-sigma-public" = {
      matchConfig.Name = "wg-sigma-public";
    };

    # The following routes traffic destined for the sigma-p2p address (floating
    # IP) to sigma through wireguard. This allows the server to have a public
    # address and help others sail the high seas even though it is behind NAT.
    netdevs."50-wg-sigma-p2p" = {
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
          PublicKey = "sigmaH/DKSU8KWyrPtucYmS2ewUvDvCNLxd/qYEo0n0=";
          PresharedKeyFile = config.age.secrets.wireguard-preshared-key-file.path;
          AllowedIPs = ["${secrets.hosts.alpha.sigma-p2p-ip-address}/32"];
          RouteTable = "main";
        }
      ];
    };
    networks."50-wg-sigma-p2p" = {
      matchConfig.Name = "wg-sigma-p2p";
    };

    # PiKVM
    netdevs."50-wg-pikvm" = {
      netdevConfig = {
        Name = "wg-pikvm";
        Kind = "wireguard";
      };
      wireguardConfig = {
        ListenPort = 51822;
        PrivateKeyFile = config.age.secrets.wireguard-private-key-file-alpha.path;
      };
      wireguardPeers = [
        {
          PublicKey = "PIKVMXKx4LFrvMc2yED48paBR0kil1IgMbGwAdV/GRM=";
          AllowedIPs = ["fd15:474a:8c5a::3/128"];
          RouteTable = "main";
        }
      ];
    };
    networks."50-wg-pikvm" = {
      matchConfig.Name = "wg-pikvm";
      address = ["fd15:474a:8c5a::a/64"];
    };
  };

  # Enable forwarding of packets
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };

  networking = {
    firewall.allowedUDPPorts = [
      51820 # wg-sigma-public
      51821 # wg-sigma-p2p
      51822 # wg-pikvm
    ];
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
