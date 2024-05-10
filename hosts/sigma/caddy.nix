{secrets, ...}: {
  services.caddy.virtualHosts = secrets.hosts.sigma.caddy.virtualHosts;

  # Add caddy to the 'torrent' group to allow viewing downloads
  users.groups.torrent.members = ["caddy"];

  age.secrets.caddy-auth-sigma = {
    file = "${secrets}/secrets/caddy-auth-sigma.age";
    mode = "400";
    owner = "caddy";
    group = "caddy";
  };
}
