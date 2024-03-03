{ config, ... }: {
  systemd.network = {
    config = {
      routeTables = {
        "wg-sigma-public" = 822944075;
        "wg-sigma-p2p" = 2553;
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
        PrivateKeyFile = config.age.secrets.wireguard-private-key-file-omega.path;
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
            AllowedIPs = [ "0.0.0.0/0" ];
            RouteTable = "wg-sigma-public";
          };
        }
      ];
    };
    networks."wg-sigma-public" = {
      name = "wg-sigma-public";
      address = [ "49.13.33.75/32" ];
      routingPolicyRules = [
        {
          routingPolicyRuleConfig = {
            From = "49.13.33.75/32";
            Table = "wg-sigma-public";
          };
        }
      ];
    };

    # The following establishes a wireguard tunnel to alpha and configures
    # receiving traffic destined for a secret address. This allows the server
    # to have a public address and help others sail the high seas even though
    # it is behind NAT.
    netdevs."51-wg-sigma-p2p" = {
      netdevConfig = {
        Name = "wg-sigma-p2p";
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wireguard-private-key-file-omega.path;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "AlphazUR/z+1DRCFSvxTeKPIJnyPQvYsDoSgESvqJhM=";
            PresharedKeyFile = config.age.secrets.wireguard-preshared-key-file.path;
            Endpoint = "alpha.caspervk.net:51821";
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
            # p2p IP.
            AllowedIPs = [ "0.0.0.0/0" ];
            RouteTable = "wg-sigma-p2p";
          };
        }
      ];
    };
    networks."wg-sigma-p2p" = {
      name = "wg-sigma-p2p";
      address = [ "a.b.c.d/32" ]; # see 51-wg-sigma-p2p.network.d/address.conf below
      routingPolicyRules = [
        {
          routingPolicyRuleConfig = {
            From = "a.b.c.d/32"; # see 51-wg-sigma-p2p.network.d/address.conf below
            Table = "wg-sigma-p2p";
          };
        }
      ];
    };
  };

  # To keep the address of the wg-sigma-p2p interface secret, it is not
  # configured here directly but instead contained in an encrypted file which
  # is decrypted and symlinked to the network's "drop-in" directly, causing it
  # to be merged into the configuration.
  environment.etc."systemd/network/wg-sigma-p2p.network.d/address.conf" = {
    source = config.age.secrets.network-wg-sigma-p2p-address.path;
  };

  age.secrets.wireguard-preshared-key-file = {
    file = ../../secrets/wireguard-preshared-key-file.age;
    mode = "640";
    owner = "root";
    group = "systemd-network";
  };

  age.secrets.wireguard-private-key-file-omega = {
    file = ../../secrets/wireguard-private-key-file-omega.age;
    mode = "640";
    owner = "root";
    group = "systemd-network";
  };

  age.secrets.network-wg-sigma-p2p-address = {
    file = ../../secrets/network-wg-sigma-p2p-address.age;
    mode = "644";
    owner = "root";
    group = "systemd-network";
  };
}