{ impermanence, pkgs, ... }: {
  # The impermanence module bind-mounts persistent files and directories, stored in /nix/persist, into the tmpfs root
  # partition on startup. For example: /nix/persist/etc/machine-id is mounted to /etc/machine-id.
  # https://github.com/nix-community/impermanence
  # https://nixos.wiki/wiki/Impermanence

  imports = [
    impermanence.nixosModules.impermanence
  ];

  # We *don't* want to use tmpfs for /tmp in case we have to put big files there. Instead, we mount it to the disk and
  # instruct systemd to clean it on boot.
  boot.tmp.cleanOnBoot = true;

  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      { directory = "/etc/NetworkManager/system-connections"; user = "root"; group = "root"; mode = "0700"; }
      { directory = "/tmp"; user = "root"; group = "root"; mode = "1777"; } # see comment above
      # With great power comes great responsibility, we get it
      { directory = "/var/db/sudo/lectured"; user = "root"; group = "root"; mode = "0700"; }
      { directory = "/var/log"; user = "root"; group = "root"; mode = "0755"; }
    ];
    files = [
      "/etc/machine-id" # needed for /var/log
    ];
    users.caspervk = {
      directories = [
        "/" # entire home directory
      ];
    };
  };
}
