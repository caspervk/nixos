{...}: {
  security.acme.certs = {
    "caspervk.net" = {
      domain = "*.caspervk.net";
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
