{
  config,
  lib,
  secrets,
  ...
}: {
  # systemd.services.qbittorrent = {
  #   description = "qBittorrent service";
  #   documentation = ["man:qbittorrent-nox(1)"];
  #   wantedBy = ["multi-user.target"];
  #   wants = ["multi-user.target"];
  #   after = ["network-online.target" "nss-lookup.target"];
  #   serviceConfig = {
  #     Type = "exec";
  #     User = "flatpak";
  #     Group = "users";
  #     ExecStart = pkgs.writers.writeBash "asd" ''
  #       while true; do ${pkgs.curl}/bin/curl --connect-timeout 1 ip.caspervk.net; echo; sleep 1; done
  #     '';
  #     RestrictNetworkInterfaces = "wg-sigma-p2p";
  #   };
  # };

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
          # See the AllowedIPs comment above for why this is necessary
          routingPolicyRuleConfig = {
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
      address = ["${secrets.sigma.sigma-p2p-ip-address}/32"];
      routingPolicyRules = [
        {
          routingPolicyRuleConfig = {
            From = "${secrets.sigma.sigma-p2p-ip-address}/32";
            Table = "wg-sigma-p2p";
          };
        }
        {
          # The deluge systemd service has
          # RestrictNetworkInterfaces=wg-sigma-p2p, but that does not tell it
          # to use the correct routing table.
          routingPolicyRuleConfig = {
            User = config.services.deluge.user;
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
        allowedTCPPorts = [22];
      };
      "wg-sigma-public" = {
        allowedTCPPorts = [22];
      };
      "wg-sigma-p2p" = {
        allowedTCPPorts = [1337];
      };
    };
  };

  age.secrets.wireguard-preshared-key-file = {
    file = "${secrets}/secrets/wireguard-preshared-key-file.age";
    mode = "640";
    owner = "root";
    group = "systemd-network";
  };

  age.secrets.wireguard-private-key-file-sigma = {
    file = "${secrets}/secrets/wireguard-private-key-file-sigma.age";
    mode = "640";
    owner = "root";
    group = "systemd-network";
  };
}
