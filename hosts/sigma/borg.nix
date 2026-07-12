{inputs, ...}: {
  imports = [
    ../../modules/borg.nix
  ];

  services.borgbackup.jobs.root.repo = "ssh://u394155-sub3@u394155.your-storagebox.de:23/./root";

  age.secrets.borg-passphrase-file = {
    file = "${inputs.secrets}/secrets/borg-passphrase-file-sigma.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
