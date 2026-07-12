{
  config,
  inputs,
  ...
}: {
  # NOTE: General syncthing configuration is in modules/base/syncthing.nix.
  services.syncthing = {
    enable = true;
    # https://wiki.nixos.org/wiki/Syncthing#Declarative_node_IDs
    cert = config.age.secrets.syncthing-zeta-cert.path;
    key = config.age.secrets.syncthing-zeta-key.path;
    settings = {
      devices = inputs.secrets.modules.syncthing.zeta.devices;
      folders = inputs.secrets.modules.syncthing.zeta.folders;
    };
  };

  age.secrets.syncthing-zeta-cert = {
    file = "${inputs.secrets}/secrets/syncthing-zeta-cert.age";
    mode = "400";
    owner = "caspervk";
    group = "syncthing";
  };

  age.secrets.syncthing-zeta-key = {
    file = "${inputs.secrets}/secrets/syncthing-zeta-key.age";
    mode = "400";
    owner = "caspervk";
    group = "syncthing";
  };
}
