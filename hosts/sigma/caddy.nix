{secrets, ...}: {
  services.caddy.virtualHosts = secrets.sigma.caddy.virtualHosts;
}
