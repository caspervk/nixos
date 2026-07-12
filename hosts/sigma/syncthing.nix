{
  config,
  inputs,
  ...
}: {
  # NOTE: General syncthing configuration is in modules/base/syncthing.nix.
  services.syncthing = {
    enable = true;
    # https://wiki.nixos.org/wiki/Syncthing#Declarative_node_IDs
    cert = config.age.secrets.syncthing-sigma-cert.path;
    key = config.age.secrets.syncthing-sigma-key.path;
    settings = {
      devices = inputs.secrets.modules.syncthing.sigma.devices;
      folders = inputs.secrets.modules.syncthing.sigma.folders;
    };
  };

  age.secrets.syncthing-sigma-cert = {
    file = "${inputs.secrets}/secrets/syncthing-sigma-cert.age";
    mode = "400";
    owner = "caspervk";
    group = "syncthing";
  };

  age.secrets.syncthing-sigma-key = {
    file = "${inputs.secrets}/secrets/syncthing-sigma-key.age";
    mode = "400";
    owner = "caspervk";
    group = "syncthing";
  };
}
