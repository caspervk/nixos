{
  config,
  inputs,
  ...
}: {
  # NOTE: General syncthing configuration is in modules/base/syncthing.nix.
  services.syncthing = {
    enable = true;
    # https://wiki.nixos.org/wiki/Syncthing#Declarative_node_IDs
    cert = config.age.secrets.syncthing-omega-cert.path;
    key = config.age.secrets.syncthing-omega-key.path;
    settings = {
      devices = inputs.secrets.modules.syncthing.omega.devices;
      folders = inputs.secrets.modules.syncthing.omega.folders;
    };
  };

  age.secrets.syncthing-omega-cert = {
    file = "${inputs.secrets}/secrets/syncthing-omega-cert.age";
    mode = "400";
    owner = "caspervk";
    group = "syncthing";
  };

  age.secrets.syncthing-omega-key = {
    file = "${inputs.secrets}/secrets/syncthing-omega-key.age";
    mode = "400";
    owner = "caspervk";
    group = "syncthing";
  };
}
