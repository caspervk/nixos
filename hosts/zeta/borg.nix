{ ... }: {
  imports = [
    ../../modules/borg.nix
  ];

  services.borgbackup.jobs.root.repo = "ssh://u394155-sub2@u394155.your-storagebox.de:23/./root";
  age.secrets.borg-passphrase-file.file = ../../secrets/borg-passphrase-file-zeta.age;
}
