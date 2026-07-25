{inputs, ...}: {
  services.caddy.virtualHosts = inputs.secrets.hosts.sigma.caddy.virtualHosts;

  # Add caddy to the 'torrent' group to allow viewing downloads
  users.groups.torrent.members = ["caddy"];

  sops.secrets.caddy-auth-sigma = {
    sopsFile = "${inputs.secrets}/secrets/caddy-auth-sigma.enc";
    mode = "400";
    owner = "caddy";
    group = "caddy";
  };
}
