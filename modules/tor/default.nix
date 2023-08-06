{ config, pkgs, ... }: {
  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "exit";
    };
    settings = {
      ContactInfo = "admin@caspervk.net";
      DirPort = 80;
      ORPort =
        # TOR requires each IPv6 address to be configured explicity
        let
          interfaces = builtins.attrValues config.networking.interfaces;
          ipv6Addresses = pkgs.lib.lists.flatten (map (interface: interface.ipv6.addresses) interfaces);
          ipv6Ports = map
            (a: {
              addr = "[${a.address}]";
              port = 443;
            })
            ipv6Addresses;
        in
        [
          443
        ] ++ ipv6Ports;
      ControlPort = 9051;
      DirPortFrontPage = builtins.toFile "tor-exit-notice.html" (builtins.readFile ./tor-exit-notice.html);
      ExitRelay = true;
      ExitPolicy = [
        "reject *:25"
        "accept *:*"
      ];
      IPv6Exit = true;
    };
  };

  environment.systemPackages = with pkgs; [
    nyx # Command-line monitor for Tor
  ];

  environment.persistence."/nix/persist" = {
    directories = [
      { directory = "/var/lib/tor/keys"; user = "tor"; group = "tor"; mode = "0700"; }
    ];
  };
}
