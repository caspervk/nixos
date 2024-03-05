{
  config,
  pkgs,
  ...
}: {
  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "exit";
    };
    settings = {
      ContactInfo = "admin@caspervk.net";
      ControlPort = 9051; # for nyx
      DirPort = 80;
      DirPortFrontPage = builtins.toFile "tor-exit-notice.html" (builtins.readFile ./tor-exit-notice.html);
      ExitRelay = true;
      IPv6Exit = true;
      ExitPolicy = [
        "reject *:25"
        "accept *:*"
      ];
    };
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
