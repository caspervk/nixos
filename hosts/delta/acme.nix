{...}: {
  security.acme.certs = {
    "caspervk.net" = {
      extraDomainNames = ["*.caspervk.net"];
      reloadServices = [
        "kresd@1.service"
        "kresd@2.service"
      ];
    };
  };
  users.groups.acme.members = [
    "knot-resolver"
  ];
}
