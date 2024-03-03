{ config, lib, pkgs, ... }: {
  # BorgBackup (short: Borg) is a deduplicating backup program.
  # https://nixos.wiki/wiki/Borg_backup
  # https://nixos.org/manual/nixos/stable/#module-borgbase
  # https://nixos.org/manual/nixos/stable/options#opt-services.borgbackup.jobs
  # https://borgbackup.readthedocs.io/en/stable/

  # To add a new host, first create a new directory for its repo on the server
  # using the admin account in keepass:
  #   ssh u394155@u394155.your-storagebox.de -p 23 mkdir -p borg/<host>
  #
  # Add a sub-account on https://robot.hetzner.com/storage. The account should
  # have "ssh" and "external reachability" enabled, and its base directory
  # should be `borg/<host>`.
  #
  # Add ssh host key for passwordless auth[1]:
  #  cat /etc/ssh/ssh_host_ed25519_key.pub | ssh u394155-subX@u394155.your-storagebox.de -p 23 install-ssh-key
  #
  # Generate passphrase for host's repository (`pwgen 64 1`) and save to
  # `secrets/borg-passphrase-file-<host>.age`.
  #
  # Set attributes:
  #   services.borgbackup.jobs.root.repo
  #   age.secrets.borg-passphrase-file.file
  #
  # [1] https://docs.hetzner.com/robot/storage-box/backup-space-ssh-keys/

  # To mount or restore a backup:
  #  sudo -s
  #  mkdir -p /mnt/borg/
  #  borg-job-root mount :: /mnt/borg/
  #  ...
  #  borg-job-root umount /mnt/borg

  services.borgbackup.jobs.root = {
    # repo set on each host

    encryption = {
      # https://borgbackup.readthedocs.io/en/stable/usage/init.html
      mode = "repokey-blake2";
      passCommand = "cat ${config.age.secrets.borg-passphrase-file.path}";
    };

    environment = {
      # Use ssh host key to connect to remote borg repo
      BORG_RSH = "ssh -o ServerAliveInterval=25 -i /etc/ssh/ssh_host_ed25519_key";
    };

    # Use a built-in heuristic to decide per chunk whether to compress or not.
    # The heuristic tries with lz4 whether the data is compressible. For
    # incompressible data, it will not use compression (uses "none"). For
    # compressible data, it uses zstd with compression level 6.
    compression = "auto,zstd,6";

    # Allows seeing repo stats with:
    #   sudo systemctl status borgbackup-job-root.service
    extraCreateArgs = "--stats --show-rc";

    # Trigger backup immediately if the last trigger was missed (e.g. if the
    # system was powered down).
    persistentTimer = true;

    # Do not try backup until network is reachable (after reboot or suspend)
    preHook = lib.mkBefore ''
      until ${pkgs.iputils}/bin/ping -qc1 u394155.your-storagebox.de; do sleep 1; done
    '';

    # Include/exclude paths matching the given patterns. The first matching
    # patterns is used, so if an include pattern (prefix `+`) matches before an
    # exclude pattern (prefix `-`), the file is backed up. Prefix `!` is
    # exclude-norecurse. See `borg help patterns` for pattern syntax.
    paths = [ "/" ];
    patterns = [
      "! /dev"
      "! /lost+found"
      "! /mnt"
      "! /nix"
      "! /proc"
      "! /run"
      "! /sys"
      "! /tmp"
      "! /var/cache"
      "! /var/run"
      "! /var/tmp"
      "! /**/found.000/*"

      "! /**/.cache"
      "! /**/Cache"
      "! /**/cache"
      "! /var/lib/docker/overlay2"
      "- *.tmp"

      "! /home/*/Android/Sdk"
      "! /home/*/Downloads"
      "! /home/*/GOG Games"
      "! /home/*/.steam"
    ];

    # Prune a repository by deleting all archives not matching any of the
    # specified retention options. See `borg help prune` for the available
    # options.
    # https://borgbackup.readthedocs.io/en/stable/usage/prune.html
    prune.keep = {
      last = 10;
      within = "1w"; # keep all archives created in the last week
      daily = 14;
      weekly = 6;
      monthly = 12;
    };
  };

  programs.ssh.knownHosts = {
    "[u394155.your-storagebox.de]:23".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
  };

  age.secrets.borg-passphrase-file = {
    # file set on each host
    mode = "400";
    owner = "root";
    group = "root";
  };
}
