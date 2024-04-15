{...}: {
  security.acme.certs."caspervk.net" = {
    domain = "*.caspervk.net";
    reloadServices = [
      "caddy.service"
    ];
  };
  users.groups.acme.members = [
    "caddy"
  ];
}
