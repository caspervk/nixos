{
  config,
  inputs,
  ...
}: {
  # NOTE: General syncthing configuration is in modules/base/syncthing.nix.
  services.syncthing = {
    enable = true;
    # https://wiki.nixos.org/wiki/Syncthing#Declarative_node_IDs
    cert = config.sops.secrets.syncthing-sigma-cert.path;
    key = config.sops.secrets.syncthing-sigma-key.path;
    settings = {
      devices = inputs.secrets.modules.syncthing.sigma.devices;
      folders = inputs.secrets.modules.syncthing.sigma.folders;
    };
  };

  sops.secrets.syncthing-sigma-cert = {
    sopsFile = "${inputs.secrets}/secrets/syncthing-sigma-cert.enc";
    mode = "0400";
    owner = config.users.users.caspervk.name;
    group = config.users.groups.syncthing.name;
  };

  sops.secrets.syncthing-sigma-key = {
    sopsFile = "${inputs.secrets}/secrets/syncthing-sigma-key.enc";
    mode = "0400";
    owner = config.users.users.caspervk.name;
    group = config.users.groups.syncthing.name;
  };
}
