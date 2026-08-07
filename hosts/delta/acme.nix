{...}: {
  security.acme.certs = {
    "caspervk.net" = {
      extraDomainNames = ["*.caspervk.net"];
      reloadServices = [
        "knot-resolver.service"
      ];
    };
  };
  users.groups.acme.members = [
    "knot-resolver"
  ];
}
