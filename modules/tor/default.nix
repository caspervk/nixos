{ pkgs, ... }: {
  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "exit";
    };
    settings = {
      ContactInfo = "admin@caspervk.net";
      Nickname = "caspervk";
      DirPort = 80;
      ORPort = 443;
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
    nyx  # Command-line monitor for Tor
  ];

  environment.persistence."/nix/persist" = {
    directories = [
      { directory = "/var/lib/tor/keys"; user = "tor"; group = "tor"; mode = "0700"; }
    ];
  };
}
