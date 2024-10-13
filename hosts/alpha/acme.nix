{lib, ...}: {
  security.acme.certs = {
    "caspervk.net" = {
      extraDomainNames = ["*.caspervk.net"];
      reloadServices = [
        "caddy.service"
        "murmur.service"
      ];
      # The NixOS Caddy module is a little too clever and sets the cert's group
      # to 'caddy', which means other services can't load it. This is not needed
      # since we handle the group membership manually.
      group = lib.mkForce "acme";
    };
    "sortseer.dk" = {
      reloadServices = [
        "caddy.service"
      ];
      group = lib.mkForce "acme";
    };
  };
  users.groups.acme.members = [
    "caddy"
    "murmur"
  ];
}
