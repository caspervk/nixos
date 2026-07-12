{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.git-syndicate.nixosModules.default
  ];

  # https://git.caspervk.net/caspervk/git-syndicate
  services.git-syndicate = {
    enable = true;
    environmentFile = config.age.secrets.git-syndicate-environment-file.path;
  };

  age.secrets.git-syndicate-environment-file = {
    file = "${inputs.secrets}/secrets/git-syndicate-environment-file.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
