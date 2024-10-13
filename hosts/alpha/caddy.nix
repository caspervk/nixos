{...}: {
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
      # allow for easier curl'ing.
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
    };
  };
}
