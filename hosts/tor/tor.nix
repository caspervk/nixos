{ ... }: {
  services.tor = {
    settings = {
      Nickname = "DXV7520";
      ORPort = [
        { addr = "91.210.59.57"; port = 443; }
        { addr = "[2a0d:3e83:1:b284::1]"; port = 443; }
      ];
    };
  };
}
