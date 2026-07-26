{
  config,
  inputs,
  ...
}: {
  services.caddy.virtualHosts = inputs.secrets.hosts.sigma.caddy.virtualHosts;

  # Add caddy to the 'torrent' group to allow viewing downloads
  users.groups.torrent.members = ["caddy"];

  sops.secrets.caddy-auth-sigma = {
    sopsFile = "${inputs.secrets}/secrets/caddy-auth-sigma.enc";
    mode = "0400";
    owner = config.users.users.caddy.name;
    group = config.users.users.caddy.group;
  };
}
