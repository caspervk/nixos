{
  config,
  quaylib,
  secrets,
  ...
}: {
  imports = [
    quaylib.nixosModules.default
  ];

  # https://git.caspervk.net/caspervk/quaylib
  services.quaylib = {
    enable = true;
    environmentFile = config.age.secrets.quaylib-environment-file.path;
  };

  age.secrets.quaylib-environment-file = {
    file = "${secrets}/secrets/quaylib-environment-file.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
