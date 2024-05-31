{lib, ...}: {
  security.acme.certs = {
    "caspervk.net" = {
      extraDomainNames = ["*.caspervk.net"];
      reloadServices = [
        "caddy.service"
        "dovecot2.service"
        "postfix.service"
      ];
      # The NixOS Caddy module is a little too clever and sets the cert's group
      # to 'caddy', which means other services can't load it. This is not needed
      # since we handle the group membership manually.
      group = lib.mkForce "acme";
    };
    "sudomail.org" = {
      reloadServices = [
        "caddy.service"
      ];
      group = lib.mkForce "acme";
    };
    "vkristensen.dk" = {
      extraDomainNames = ["*.vkristensen.dk"];
      reloadServices = [
        "caddy.service"
      ];
      group = lib.mkForce "acme";
    };
  };
  users.groups.acme.members = [
    "caddy"
    "dovecot2"
    "postfix"
  ];
}
