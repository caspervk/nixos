{secrets, ...}: {
  # See modules/server/caddy.nix
  services.caddy = {
    # Wildcard certificates are used whenever possible to avoid leaking domains
    # to the certificate transparency logs.
    virtualHosts = let
      # https://caddy.community/t/caddy-server-that-returns-only-ip-address-as-text/6928
      ipConfig = ''
        templates
        header Content-Type text/plain
        respond "{{.RemoteIP}}"
      '';
    in {
      # Explicit http:// and https:// disables automatic HTTPS redirect to
      # allow for easier curl'ing of ip.caspervk.net.
      "http://ip.caspervk.net" = {
        extraConfig = ipConfig;
      };
      "https://ip.caspervk.net" = {
        useACMEHost = "caspervk.net";
        extraConfig = ipConfig;
      };
      "sortseer.dk" = {
        useACMEHost = "sortseer.dk";
        extraConfig = ''
          redir https://git.caspervk.net/caspervk/sortseer
        '';
      };
      # We do not need TLS since the webtunnel is proxied through NSA^W
      # Cloudflare. This is normally bad, but it's hard for freedom haters to
      # block 1/3rd of the internet, so it's actually good.
      # https://community.torproject.org/relay/setup/webtunnel/
      "${secrets.hosts.alpha.tor.webtunnel-host}" = {
        extraConfig = ''
          tls internal
          reverse_proxy ${secrets.hosts.alpha.tor.webtunnel-path} localhost:15000
        '';
      };
    };
  };
}
