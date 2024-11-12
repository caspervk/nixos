{pkgs, ...}: {
  services.tor = {
    enable = true;
    openFirewall = true;
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
          port = 443;
        }
        {
          addr = "[2a0c:5700:3133:650:b0ea:eeff:fedb:1f7b]";
          port = 443;
        }
      ];
      ControlPort = 9051; # for nyx
      DirPort = 80;
      DirPortFrontPage = builtins.toFile "tor-exit-notice.html" (builtins.readFile ./tor-exit-notice.html);
      ExitRelay = true;
      IPv6Exit = true;
      ExitPolicy = [
        "reject *:22"
        "reject *:25"
        "accept *:*"
      ];
    };
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

  environment.systemPackages = with pkgs; [
    nyx # Command-line monitor for Tor
  ];

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/tor";
        user = "tor";
        group = "tor";
        mode = "0700";
      }
    ];
  };
}
