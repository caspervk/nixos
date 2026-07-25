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
    environmentFile = config.sops.secrets.git-syndicate-environment-file.path;
  };

  sops.secrets.git-syndicate-environment-file = {
    sopsFile = "${inputs.secrets}/secrets/git-syndicate-environment-file.enc";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
