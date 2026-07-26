{
  config,
  inputs,
  ...
}: {
  imports = [
    ../../modules/borg.nix
  ];

  services.borgbackup.jobs.root.repo = "ssh://u394155-sub3@u394155.your-storagebox.de:23/./root";

  sops.secrets.borg-passphrase-file = {
    sopsFile = "${inputs.secrets}/secrets/borg-passphrase-file-sigma.enc";
    mode = "0400";
    owner = config.users.users.root.name;
    group = config.users.users.root.group;
  };
}
