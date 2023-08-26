{ impermanence, ... }: {
  # Impermanence in NixOS is where the root directory isn't permanent, but gets
  # wiped every reboot (such as by mounting it as tmpfs). Such a setup is
  # possible because NixOS only needs /boot and /nix in order to boot, all
  # other system files are simply links to files in /nix.

  # The impermanence module bind-mounts persistent files and directories,
  # stored in /nix/persist, into the tmpfs root partition on startup. For
  # example: /nix/persist/etc/machine-id is mounted to /etc/machine-id.
  # https://github.com/nix-community/impermanence
  # https://nixos.wiki/wiki/Impermanence
  # https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/

  imports = [
    impermanence.nixosModules.impermanence
  ];

  # We *don't* want to use tmpfs for /tmp in case we have to put big files
  # there. Instead, we mount it to the disk and instruct systemd to clean it on
  # boot.
  # TODO: There might be a way to configure /tmp to be in-memory storage until
  # it gets too big.
  boot.tmp.cleanOnBoot = true;

  # Each module will configure the paths they need persisted. Here we define
  # some general system paths that don't really fit anywhere else.
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      # See comment above for /tmp
      { directory = "/tmp"; user = "root"; group = "root"; mode = "1777"; }
      # With great power comes great responsibility, we get it
      { directory = "/var/db/sudo/lectured"; user = "root"; group = "root"; mode = "0700"; }
      # Save the last run time of persistent timers so systemd knows if they was missed
      { directory = "/var/lib/systemd/timers"; user = "root"; group = "root"; mode = "0755"; }
      { directory = "/var/log"; user = "root"; group = "root"; mode = "0755"; }
    ];
    files = [
      "/etc/machine-id" # needed for /var/log
    ];
    users.caspervk = {
      directories = [
        "/" # entire home directory (TODO)
      ];
    };
  };
}
