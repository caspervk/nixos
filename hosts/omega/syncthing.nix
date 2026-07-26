{
  config,
  inputs,
  ...
}: {
  # NOTE: General syncthing configuration is in modules/base/syncthing.nix.
  services.syncthing = {
    enable = true;
    # https://wiki.nixos.org/wiki/Syncthing#Declarative_node_IDs
    cert = config.sops.secrets.syncthing-omega-cert.path;
    key = config.sops.secrets.syncthing-omega-key.path;
    settings = {
      devices = inputs.secrets.modules.syncthing.omega.devices;
      folders = inputs.secrets.modules.syncthing.omega.folders;
    };
  };

  sops.secrets.syncthing-omega-cert = {
    sopsFile = "${inputs.secrets}/secrets/syncthing-omega-cert.enc";
    mode = "400";
    owner = config.users.users.caspervk.name;
    group = config.users.groups.syncthing.name;
  };

  sops.secrets.syncthing-omega-key = {
    sopsFile = "${inputs.secrets}/secrets/syncthing-omega-key.enc";
    mode = "400";
    owner = config.users.users.caspervk.name;
    group = config.users.groups.syncthing.name;
  };
}
