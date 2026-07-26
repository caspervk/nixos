{
  config,
  inputs,
  ...
}: {
  imports = [
    ../../modules/borg.nix
  ];

  services.borgbackup.jobs.root.repo = "ssh://u394155-sub2@u394155.your-storagebox.de:23/./root";
  sops.secrets.borg-passphrase-file = {
    sopsFile = "${inputs.secrets}/secrets/borg-passphrase-file-zeta.enc";
    mode = "400";
    owner = config.users.users.root.name;
    group = config.users.users.root.group;
  };
}
