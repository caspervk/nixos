{sortseer, ...}: {
  imports = [
    sortseer.nixosModules.default
  ];

  # https://git.caspervk.net/caspervk/sortseer
  services.sortseer.enable = true;

  networking.firewall = {
    allowedTCPPorts = [25];
  };
}
