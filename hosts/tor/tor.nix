{
  config,
  pkgs,
  secrets,
  ...
}: let
  mkTorConfig = {
    orPort,
    controlPort,
    dirPort,
  }: {
    enable = true;
    relay = {
      enable = true;
      role = "exit";
    };
    settings = {
      Nickname = "DXV7520";
      ContactInfo = "admin@caspervk.net";
      ORPort = [
        {
          addr = "185.231.102.51";
          port = orPort;
        }
        {
          addr = "[2a0c:5700:3133:650:b0ea:eeff:fedb:1f7b]";
          port = orPort;
        }
      ];
      ControlPort = controlPort; # for nyx, localhost only
      DirPort = dirPort;
      DirPortFrontPage = builtins.toFile "tor-exit-notice.html" (builtins.readFile ./tor-exit-notice.html);
      ExitRelay = true;
      IPv6Exit = true;
      ExitPolicy = [
        "reject *:22"
        "reject *:25"
        "accept *:*"
      ];
      # https://support.torproject.org/relay-operators/multiple-relays/
      MyFamily = builtins.concatStringsSep "," [
        "1B9D2C9E0EFE2C6BD23D62B2FCD145886AD242D1" # instance 1
      ];
    };
  };
in {
  containers.tor-1 = {
    autoStart = true;
    # TODO: what does ephemeral mean?
    ephemeral = true;
    bindMounts = {
      # https://support.torproject.org/relay-operators/upgrade-or-move/
      "/var/lib/tor/keys/ed25519_master_id_secret_key".hostPath = config.age.secrets.tor-1-ed25519-master-id-secret-key.path;
      "/var/lib/tor/keys/secret_id_key".hostPath = config.age.secrets.tor-1-secret-id-key.path;
    };
    config = {config, ...}: {
      services.tor = mkTorConfig {
        orPort = 443;
        controlPort = 9051;
        dirPort = 80;
      };
      system.stateVersion = config.system.stateVersion;
    };
  };

  environment.systemPackages = with pkgs; [
    nyx # Command-line monitor for Tor
  ];

  age.secrets.tor-ed25519-master-id-secret-key = {
    file = "${secrets}/secrets/tor-1-ed25519-master-id-secret-key.age";
    mode = "400";
    owner = "root";
    group = "root";
  };

  age.secrets.tor-secret-id-key = {
    file = "${secrets}/secrets/tor-1-secret-id-key.age";
    mode = "400";
    owner = "root";
    group = "root";
  };

  # https://support.torproject.org/relay-operators/#relay-operators_relay-bridge-overloaded
  # https://lists.torproject.org/pipermail/tor-talk/2012-August/025296.html
  # https://www.ibm.com/docs/en/linux-on-systems?topic=recommendations-network-performance-tuning
  # https://github.com/Enkidu-6/tor-ddos
  boot.kernel.sysctl = {
    # Increase the maximum size of the network interface's receive queue, used
    # to store received frames after removing them from the network adapter's
    # ring buffer. High speed adapters should use a high value to prevent the
    # queue from becoming full and dropping packets causing retransmits.
    "net.core.netdev_max_backlog" = 262144;
    # Increase TCP read/write buffers to enable scaling to a larger window
    # size. Larger windows increase the amount of data to be transferred before
    # an acknowledgement (ACK) is required. This reduces overall latencies and
    # results in increased throughput.
    "net.core.rmem_max" = 33554432;
    "net.core.wmem_max" = 33554432;
    "net.ipv4.tcp_rmem" = "4096 131072 33554432";
    "net.ipv4.tcp_wmem" = "4096 65536 33554432";
    # Reduce the length of time an orphaned connection will wait before it is
    # aborted. For workloads or systems that generate or support high levels of
    # network traffic, it can be advantageous to more aggressively reclaim dead
    # or stale resources.
    "net.ipv4.tcp_fin_timeout" = 10;
    # Maximal number of TCP sockets not attached to any user file handle, held
    # by system. If this number is exceeded orphaned connections are reset
    # immediately and warning is printed. This limit exists only to prevent
    # simple DoS attacks, you _must_ not rely on this or lower the limit
    # artificially, but rather increase it (probably, after increasing
    # installed memory), if network conditions require more than default value,
    # and tune network services to linger and kill such states more
    # aggressively. Let me to remind again: each orphan eats up to ~64K of
    # unswappable memory.
    "net.ipv4.tcp_max_orphans" = 262144;
    # Maximal number of timewait sockets held by system simultaneously. If this
    # number is exceeded time-wait socket is immediately destroyed and warning
    # is printed. This limit exists only to prevent simple DoS attacks, you
    # _must_ not lower the limit artificially, but rather increase it
    # (probably, after increasing installed memory), if network conditions
    # require more than default value.
    "net.ipv4.tcp_max_tw_buckets" = 2097152;
    # In high traffic environments, sockets are created and destroyed at very
    # high rates. This parameter, when set, allows "no longer needed" and
    # "about to be destroyed" sockets to be used for new connections. When
    # enabled, this parameter can bypass the allocation and initialization
    # overhead normally associated with socket creation saving CPU cycles,
    # system load and time.
    "net.ipv4.tcp_tw_reuse" = 1;
    # Aggressivelly check for and close broken connections
    "net.ipv4.tcp_keepalive_time" = 60;
    "net.ipv4.tcp_keepalive_probes" = 3;
    "net.ipv4.tcp_keepalive_intvl" = 10;
    # Increase the length of the SYN queue and socket listen() backlog to
    # accommodate more connections waiting to connect.
    "net.ipv4.tcp_max_syn_backlog" = 262144;
    "net.core.somaxconn" = 32768;
    # Expand local port range used for outgoing connections
    "net.ipv4.ip_local_port_range" = "1025 65530";
    # Disable RFC1323 timestamps (TODO: why?)
    "net.ipv4.tcp_timestamps" = 0;
  };
}
