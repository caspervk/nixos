{...}: {
  security.acme.certs."caspervk.net" = {
    domain = "*.caspervk.net";
    reloadServices = [
      "caddy.service"
      "murmur.service"
    ];
  };
  users.groups.acme.members = [
    "caddy"
    "murmur"
  ];
}
