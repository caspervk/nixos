{...}: {
  security.acme.certs."caspervk.net" = {
    domain = "*.caspervk.net";
    reloadServices = [
      "murmur.service"
    ];
  };
  users.groups.acme.members = [
    "murmur"
  ];
}
