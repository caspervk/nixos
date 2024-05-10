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
    networks."wg-sigma-public" = {
      name = "wg-sigma-public";
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
    netdevs."51-wg-sigma-p2p" = {
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
    networks."wg-sigma-p2p" = {
      name = "wg-sigma-p2p";
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
      "enp5s0" = {
        allowedTCPPorts = [
          1234 # ad hoc
          1337 # ad hoc
          139 # Samba
          22000 # syncthing
          22 # SSH
          25 # Mail SMTP
          443 # Caddy
          445 # Samba
          465 # Mail ESMTP
          8000 # ad hoc
          8080 # ad hoc
          80 # Caddy
          993 # Mail IMAPS
        ];
        allowedUDPPorts = [
          139 # Samba
          21027 # syncthing
          22000 # syncthing
          445 # Samba
        ];
      };
      "wg-sigma-public" = {
        allowedTCPPorts = [
          1234 # ad hoc
          1337 # ad hoc
          22000 # syncthing
          22 # SSH
          25 # Mail SMTP
          443 # Caddy
          465 # Mail ESMTP
          8000 # ad hoc
          8080 # ad hoc
          80 # Caddy
          993 # Mail IMAPS
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
