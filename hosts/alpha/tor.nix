{
  pkgs,
  secrets,
  ...
}: {
  # Bridges are Tor relays that help circumvent censorship. WebTunnel is a
  # censorship-resistant pluggable transport designed to mimic encrypted web
  # traffic (HTTPS). It works by wrapping the payload connection into a
  # WebSocket-like HTTPS connection, appearing to network observers as an
  # ordinary HTTPS (WebSocket) connection.
  # https://community.torproject.org/relay/setup/webtunnel/
  # https://community.torproject.org/relay/setup/webtunnel/source/
  #
  # Test the bridge by setting
  #   webtunnel 10.0.0.2:443 FINGERPRINT url=https://yourdomain/path
  # in the Tor Browser settings (from webtunnel/source final notes).
  services.tor = {
    enable = true;
    relay = {
      enable = true;
      role = "bridge";
    };
    settings = {
      Nickname = "DXV7520WebTunnel";
      ContactInfo = "email:admin[]caspervk.net url:caspervk.net proof:dns-rsa ciissversion:2";
      ORPort = [
        {
          addr = "127.0.0.1";
          port = "auto";
        }
        {
          addr = "[::1]";
          port = "auto";
        }
      ];
      AssumeReachable = true;
      ServerTransportPlugin.transports = ["webtunnel"];
      ServerTransportPlugin.exec = "${pkgs.webtunnel}/bin/server";
      ServerTransportListenAddr = "webtunnel 127.0.0.1:15000";
      ServerTransportOptions = "webtunnel url=${secrets.hosts.alpha.tor.webtunnel-host + secrets.hosts.alpha.tor.webtunnel-path}";
    };
  };

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
