{
  config,
  pkgs,
  ...
}: {
  # TODO: Explain why we use containers (tor is bad: cpu)
  # > sudo systemctl -M tor-1 status tor
  # > sudo journalctl -M tor-1 -eu tor.service
  containers = let
    mkTorContainer = {
      stateDir,
      orPort,
      controlPort,
    }: {
      autoStart = true;
      ephemeral = true; # impermanence
      bindMounts = {
        "/var/lib/tor/" = {
          hostPath = stateDir;
          isReadOnly = false;
        };
      };
      config = {...}: {
        services.tor = {
          enable = true;
          relay = {
            enable = true;
            role = "exit";
          };
          # https://manpages.debian.org/testing/tor/torrc.5.en.html
          settings = {
            Nickname = "DXV7520";
            ContactInfo = "admin@caspervk.net";
            ORPort = [
              {
                addr = "31.133.0.235";
                port = orPort;
              }
              {
                addr = "[2001:67c:2044:c141::1:6431:1]";
                port = orPort;
              }
            ];
            ControlPort = controlPort; # for nyx, localhost only
            ExitRelay = true;
            IPv6Exit = true;
            ExitPolicy = [
              "reject *:22"
              "reject *:25"
              "accept *:*"
            ];
            # https://community.torproject.org/relay/setup/post-install/family-ids/
            FamilyId = "2KNVE7dHXshhscLKk3sZ1Dj19XV+NUHjE568YqwRHtg";
            # https://support.torproject.org/relay-operators/multiple-relays/
            # Note that bridges should not configure their own -- or be listed
            # in other relay's -- MyFamily as per the torrc man page.
            MyFamily = builtins.concatStringsSep "," [
              "1B9D2C9E0EFE2C6BD23D62B2FCD145886AD242D1" # /var/lib/tor-1/fingerprint
              "293CE00D11B1D8B99AE8811CBDFDA3F353353710" # /var/lib/tor-2/fingerprint
              "27FF3E6979EF6570B9EB3B53B11964FE08F36F19" # /var/lib/tor-3/fingerprint
              "C2041A1CE9FDFDB13572D946A3055310FD48A595" # /var/lib/tor-4/fingerprint
            ];
          };
        };
        # On 03/11/2026 03.40, forest via tor-relays wrote:
        # > use a memory allocator that is more resistant to memory
        # > fragmentation. 1AEO has found mimalloc2 is the best, but Debian only
        # > has mimalloc3 which is actually worse. I use jemalloc2 on all of my
        # > relays which substantially reduces memory use and eliminates
        # > thrashing.
        systemd.services.tor.environment.LD_PRELOAD = "${pkgs.jemalloc}/lib/libjemalloc.so";
        system.stateVersion = config.system.stateVersion;
      };
    };
  in {
    tor-1 = mkTorContainer {
      stateDir = "/var/lib/tor-1/";
      orPort = 443;
      controlPort = 9051;
    };
    tor-2 = mkTorContainer {
      stateDir = "/var/lib/tor-2/";
      orPort = 444;
      controlPort = 9052;
    };
    tor-3 = mkTorContainer {
      stateDir = "/var/lib/tor-3/";
      orPort = 445;
      controlPort = 9053;
    };
    tor-4 = mkTorContainer {
      stateDir = "/var/lib/tor-4/";
      orPort = 446;
      controlPort = 9054;
    };
  };

  environment.systemPackages = [
    pkgs.nyx # Command-line monitor for Tor
  ];

  # Serve Exit Relay Notice HTML page
  # https://community.torproject.org/relay/setup/exit/
  services.caddy = {
    enable = true;
    virtualHosts = {
      "http://" = {
        extraConfig = ''
          header Content-Type text/html
          respond `${builtins.readFile ./tor-exit-notice.html}`
        '';
      };
    };
  };

  boot.kernel.sysctl = {
    "net.core.netdev_max_backlog" = 262144;
    "net.core.rmem_max" = 33554432;
    "net.core.somaxconn" = 32768;
    "net.core.wmem_max" = 33554432;
    "net.ipv4.ip_local_port_range" = "1025 65530";
    "net.ipv4.tcp_ecn" = 3;
    "net.ipv4.tcp_fin_timeout" = 10;
    "net.ipv4.tcp_keepalive_time" = 60;
    "net.ipv4.tcp_max_orphans" = 32768;
    "net.ipv4.tcp_max_syn_backlog" = 262144;
    "net.ipv4.tcp_max_tw_buckets" = 2097152;
    "net.ipv4.tcp_rmem" = "4096 131072 33554432";
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_wmem" = "4096 65536 33554432";
  };

  # Mounting /var/lib/tor/ relies on the 'tor' user having the same static
  # uid/gid inside and outside the container. This might break if NixOS
  # switches to a DynamicUser for the tor service.
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/tor-1";
        mode = "0700";
        user = toString config.ids.uids.tor;
        group = toString config.ids.gids.tor;
      }
      {
        directory = "/var/lib/tor-2";
        mode = "0700";
        user = toString config.ids.uids.tor;
        group = toString config.ids.gids.tor;
      }
      {
        directory = "/var/lib/tor-3";
        mode = "0700";
        user = toString config.ids.uids.tor;
        group = toString config.ids.gids.tor;
      }
      {
        directory = "/var/lib/tor-4";
        mode = "0700";
        user = toString config.ids.uids.tor;
        group = toString config.ids.gids.tor;
      }
    ];
  };
}
