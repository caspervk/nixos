{impermanence, ...}: {
  # Impermanence in NixOS is where the root directory isn't permanent, but gets
  # wiped every reboot (such as by mounting it as tmpfs). Such a setup is
  # possible because NixOS only needs /boot and /nix in order to boot, all
  # other system files are simply links to files in /nix.

  # The impermanence module bind-mounts persistent files and directories,
  # stored in /nix/persist, into the tmpfs root partition on startup. For
  # example: /nix/persist/etc/machine-id is mounted to /etc/machine-id.
  # https://github.com/nix-community/impermanence
  # https://wiki.nixos.org/wiki/Impermanence
  # https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/

  imports = [
    impermanence.nixosModules.impermanence
  ];

  # Each module will configure the paths they need persisted. Here we define
  # some general system paths that don't really fit anywhere else.
  # https://nixos.org/manual/nixos/stable/#sec-nixos-state
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      {
        # /var/lib/nixos should persist: it holds state needed to generate
        # stable uids and gids for declaratively-managed users and groups, etc.
        directory = "/var/lib/nixos";
        user = "root";
        group = "root";
        mode = "0755";
      }
      {
        # systemd expects its state directory to persist.
        directory = "/var/lib/systemd";
        user = "root";
        group = "root";
        mode = "0755";
      }
      {
        # If (locally) persisting the entire log is desired, it is recommended
        # to make all of /var/log/journal persistent.
        directory = "/var/log";
        user = "root";
        group = "root";
        mode = "0755";
      }
      {
        # /var/tmp is meant for temporary files that are preserved across
        # reboots. Some programs might store files too big for in-memory /tmp
        # there. Files are automatically cleaned by systemd.
        directory = "/var/tmp";
        user = "root";
        group = "root";
        mode = "1777";
      }
    ];
    files = [
      # systemd uses per-machine identifier which must be unique and
      # persistent; otherwise, the system journal may fail to list earlier
      # boots, etc. systemd generates a random machine-id during boot if it
      # does not already exist, and persists it in /etc/machine-id.
      "/etc/machine-id"
    ];
    users.caspervk = {
      directories = [
        "/" # entire home directory (TODO?)
      ];
    };
  };
}
