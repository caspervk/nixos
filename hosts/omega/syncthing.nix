{
  config,
  secrets,
  ...
}: {
  # NOTE: General syncthing configuration is in modules/base/syncthing.nix.
  services.syncthing = {
    enable = true;
    # https://wiki.nixos.org/wiki/Syncthing#Declarative_node_IDs
    cert = config.age.secrets.syncthing-omega-cert.path;
    key = config.age.secrets.syncthing-omega-key.path;
    settings = {
      devices = secrets.modules.syncthing.omega.devices;
      folders = secrets.modules.syncthing.omega.folders;
    };
  };

  age.secrets.syncthing-omega-cert = {
    file = "${secrets}/secrets/syncthing-omega-cert.age";
    mode = "400";
    owner = "caspervk";
    group = "syncthing";
  };

  age.secrets.syncthing-omega-key = {
    file = "${secrets}/secrets/syncthing-omega-key.age";
    mode = "400";
    owner = "caspervk";
    group = "syncthing";
  };
}
