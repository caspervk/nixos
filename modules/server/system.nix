{
  config,
  inputs,
  ...
}: {
  # Automatically `nixos-rebuild switch` daily with the latest configuration
  # from git. This overwrites any uncommitted changes in ~/nixos/, which is why
  # it is only enabled on servers. Note that this requires updating flake.lock
  # in the repository periodically (see .forgejo/workflows/update.yaml).
  system.autoUpgrade = {
    enable = true;
    flake = "git+https://git.caspervk.net/caspervk/nixos.git";
    randomizedDelaySec = "45min";
  };

  systemd.services.nixos-upgrade = {
    # Retry on failure, but stop if the service fails three times in five
    # minutes. Useful to properly upgrade services which fail due to
    # intermittent network issues.
    serviceConfig.Restart = "on-failure";
    serviceConfig.RestartSec = "30s";
    unitConfig.StartLimitIntervalSec = "5min";
    unitConfig.StartLimitBurst = 3;
    # The `nixos-secrets` flake input requires authentication
    environment.GIT_SSH_COMMAND = "ssh -i ${config.sops.secrets.autoupgrade-deploy-key.path}";
  };

  sops.secrets.autoupgrade-deploy-key = {
    sopsFile = "${inputs.secrets}/secrets/autoupgrade-deploy-key.enc";
    mode = "0400";
    owner = config.users.users.root.name;
    group = config.users.users.root.group;
  };
}
