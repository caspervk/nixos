{
  config,
  lib,
  secrets,
  ...
}: {
  systemd.network = {
    config = {
      routeTables = {
        "wg-sigma-public" = 42;
        "wg-sigma-p2p" = 6881;
      };
    };

    # The following configures the server as a typical "home router" with a
    # DHCP server to hand out client addresses and NATing. The server's own
    # address is requested from the ISP through DHCP.
    networks."10-wan" = {
      # Realtek motherboard port
      matchConfig.Name = "enp5s0";
      networkConfig = {
        # Enable DHCP *client* to request an IP address from the ISP. Denmark
        # does not use IPv6.
        DHCP = "ipv4";
      };
    };
    networks."20-lan" = {
      # Intel pci port (right)
      matchConfig.Name = "enp4s0f0";
      address = [
        "192.168.0.1/24"
      ];
      networkConfig = {
        # Enable DHCP *server*. By default, the DHCP leases handed out to
        # clients contain DNS information from our own uplink interface and
        # specify our own address as the router.
        # See offered DHCP leases with `networkctl status enp4s0f0`.
        DHCPServer = true;
        # Enable IP masquerading (NAT) to rewrite the address on packets
        # forwarded from this interface so as to appear as coming from this
        # host. Required to share a single external IP address and act as a
        # "router" since each lan host does not get its own public IP address.
        IPMasquerade = "ipv4";
      };
      dhcpServerConfig = {
        # TODO
        # networks."00-ignore-dhcp-dns" = {
        #   matchConfig.Name = "*";
        #   dhcpV4Config.UseDNS = false;
        #   dhcpV6Config.UseDNS = false;
        # };
        # Explicitly override the propagated DNS servers
        DNS = config.networking.nameservers;
      };
    };

    # The following establishes a wireguard tunnel to alpha and configures
    # receiving traffic destined for 49.13.33.75. This allows us to have a
    # public address even though we are behind NAT.
    netdevs."50-wg-sigma-public" = {
      netdevConfig = {
        Name = "wg-sigma-public";
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wireguard-private-key-file-sigma.path;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "AlphazUR/z+1DRCFSvxTeKPIJnyPQvYsDoSgESvqJhM=";
            PresharedKeyFile = config.age.secrets.wireguard-preshared-key-file.path;
            Endpoint = "alpha.caspervk.net:51820";
            # Keep NAT mappings and stateful firewalls open at the ISP
            PersistentKeepalive = 25;
            # AllowedIPs is both an ACL for incoming traffic, as well as a
            # routing table specifying to which peer outgoing traffic should be
            # sent. We want to allow incoming traffic from any address on the
            # internet (routed through alpha), but only replies to this should
            # be routed back over wireguard. Unlike if we had used NAT, IP
            # routes are stateless, so we have no notion of "replies". Instead,
            # we add these routes to a specific routing table and configure a
            # routing policy rule to only use it for packets being sent as the
            # public IP.
            AllowedIPs = ["0.0.0.0/0"];
            RouteTable = "wg-sigma-public";
          };
        }
      ];
    };
    networks."50-wg-sigma-public" = {
      matchConfig.Name = "wg-sigma-public";
      address = ["49.13.33.75/32"];
      routingPolicyRules = [
        {
          # The postfix systemd service has
          # RestrictNetworkInterfaces=wg-sigma-public, but that does not tell
          # it to use the correct routing table.
          routingPolicyRuleConfig = {
            Priority = 10;
            User = config.services.postfix.user;
            Table = "wg-sigma-public";
          };
        }
        {
          # Allow hosts on the local network to contact us directly on the
          # public address instead of routing the packet through Wireguard and
          # back again.
          routingPolicyRuleConfig = {
            Priority = 500;
            From = "49.13.33.75/32";
            To = "192.168.0.0/24";
            Table = "main";
          };
        }
        {
          # See the AllowedIPs comment above for why this is necessary
          routingPolicyRuleConfig = {
            Priority = 1000;
            From = "49.13.33.75/32";
            Table = "wg-sigma-public";
          };
        }
      ];
    };

    # The following establishes a wireguard tunnel to alpha and configures
    # receiving traffic destined for the sigma-p2p address. This allows the
    # server to have a public address and help others sail the high seas even
    # though it is behind NAT.
    netdevs."50-wg-sigma-p2p" = {
      netdevConfig = {
        Name = "wg-sigma-p2p";
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wireguard-private-key-file-sigma.path;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "AlphazUR/z+1DRCFSvxTeKPIJnyPQvYsDoSgESvqJhM=";
            PresharedKeyFile = config.age.secrets.wireguard-preshared-key-file.path;
            Endpoint = "alpha.caspervk.net:51821";
            PersistentKeepalive = 25;
            AllowedIPs = ["0.0.0.0/0"];
            RouteTable = "wg-sigma-p2p";
          };
        }
      ];
    };
    networks."50-wg-sigma-p2p" = {
      matchConfig.Name = "wg-sigma-p2p";
      address = ["${secrets.hosts.sigma.sigma-p2p-ip-address}/32"];
      routingPolicyRules = [
        {
          # The deluge systemd service has
          # RestrictNetworkInterfaces=wg-sigma-p2p, but that does not tell it
          # to use the correct routing table.
          routingPolicyRuleConfig = {
            Priority = 10;
            User = config.services.deluge.user;
            Table = "wg-sigma-p2p";
          };
        }
        {
          routingPolicyRuleConfig = {
            Priority = 1000;
            From = "${secrets.hosts.sigma.sigma-p2p-ip-address}/32";
            Table = "wg-sigma-p2p";
          };
        }
      ];
    };
  };

  # Force explicit firewall configuration to ensure we allow the right services
  # on the right interfaces.
  networking.firewall = {
    allowedTCPPorts = lib.mkForce [];
    allowedUDPPorts = lib.mkForce [];
    allowedTCPPortRanges = lib.mkForce [];
    allowedUDPPortRanges = lib.mkForce [];
    interfaces = {
      "enp4s0f0" = {
        allowedTCPPorts = [
          22 # SSH
          25 # Mail SMTP
          80 # Caddy
          139 # Samba
          443 # Caddy
          445 # Samba
          465 # Mail ESMTP
          993 # Mail IMAPS
          1234 # ad hoc
          1337 # ad hoc
          8000 # ad hoc
          8080 # ad hoc
          22000 # syncthing
        ];
        allowedUDPPorts = [
          67 # DHCP server
          445 # Samba
          21027 # syncthing
          22000 # syncthing
        ];
      };
      "wg-sigma-public" = {
        allowedTCPPorts = [
          22 # SSH
          25 # Mail SMTP
          80 # Caddy
          443 # Caddy
          465 # Mail ESMTP
          993 # Mail IMAPS
          1234 # ad hoc
          1337 # ad hoc
          8000 # ad hoc
          8080 # ad hoc
          22000 # syncthing
        ];
        allowedUDPPorts = [
          21027 # syncthing
          22000 # syncthing
        ];
      };
      "wg-sigma-p2p" = {
        allowedTCPPorts = [
          60881 # Deluge
        ];
        allowedUDPPorts = [
          60881 # Deluge
        ];
      };
    };
  };

  # Enable forwarding of packets
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };

  age.secrets.wireguard-preshared-key-file = {
    file = "${secrets}/secrets/wireguard-preshared-key-file.age";
    mode = "440";
    owner = "root";
    group = "systemd-network";
  };

  age.secrets.wireguard-private-key-file-sigma = {
    file = "${secrets}/secrets/wireguard-private-key-file-sigma.age";
    mode = "440";
    owner = "root";
    group = "systemd-network";
  };
}
