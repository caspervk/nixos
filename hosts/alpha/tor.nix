{
  pkgs,
  secrets,
  ...
}: let
  # The websocket pluggable-transport isn't in nixpkgs yet.
  # https://github.com/NixOS/nixpkgs/pull/277487
  webtunnel = pkgs.buildGoModule {
    pname = "webtunnel";
    version = "main";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.torproject.org";
      group = "tpo";
      owner = "anti-censorship/pluggable-transports";
      repo = "webtunnel";
      rev = "e64b1b3562f3ab50d06141ecd513a21ec74fe8c6";
      hash = "sha256-25ZtoCe1bcN6VrSzMfwzT8xSO3xw2qzE4Me3Gi4GbVs=";
    };
    vendorHash = "sha256-3AAPySLAoMimXUOiy8Ctl+ghG5q+3dWRNGXHpl9nfG0=";
  };
in {
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
      ContactInfo = "admin@caspervk.net";
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
      ServerTransportPlugin.exec = "${webtunnel}/bin/server";
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
