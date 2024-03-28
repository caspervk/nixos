{secrets, ...}: {
  imports = [
    ../../modules/borg.nix
  ];

  services.borgbackup.jobs.root.repo = "ssh://u394155-sub1@u394155.your-storagebox.de:23/./root";

  age.secrets.borg-passphrase-file = {
    file = "${secrets}/secrets/borg-passphrase-file-omega.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
