{secrets, ...}: {
  services.caddy.virtualHosts = secrets.sigma.caddy.virtualHosts;

  age.secrets.caddy-auth-sigma = {
    file = "${secrets}/secrets/caddy-auth-sigma.age";
    mode = "600";
    owner = "caddy";
    group = "caddy";
  };
}
