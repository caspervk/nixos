{
  config,
  git-syndicate,
  secrets,
  ...
}: {
  imports = [
    git-syndicate.nixosModules.default
  ];

  # https://git.caspervk.net/caspervk/git-syndicate
  services.git-syndicate = {
    enable = true;
    environmentFile = config.age.secrets.git-syndicate-environment-file.path;
  };

  age.secrets.git-syndicate-environment-file = {
    file = "${secrets}/secrets/git-syndicate-environment-file.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
