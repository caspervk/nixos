{
  config,
  inputs,
  ...
}: {
  # NOTE: General syncthing configuration is in modules/base/syncthing.nix.
  services.syncthing = {
    enable = true;
    # https://wiki.nixos.org/wiki/Syncthing#Declarative_node_IDs
    cert = config.sops.secrets.syncthing-zeta-cert.path;
    key = config.sops.secrets.syncthing-zeta-key.path;
    settings = {
      devices = inputs.secrets.modules.syncthing.zeta.devices;
      folders = inputs.secrets.modules.syncthing.zeta.folders;
    };
  };

  sops.secrets.syncthing-zeta-cert = {
    sopsFile = "${inputs.secrets}/secrets/syncthing-zeta-cert.enc";
    mode = "400";
    owner = config.users.users.caspervk.name;
    group = config.users.groups.syncthing.name;
  };

  sops.secrets.syncthing-zeta-key = {
    sopsFile = "${inputs.secrets}/secrets/syncthing-zeta-key.enc";
    mode = "400";
    owner = config.users.users.caspervk.name;
    group = config.users.groups.syncthing.name;
  };
}
