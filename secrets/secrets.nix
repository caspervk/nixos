# This file is NOT imported into the NixOS configuration. It is only used for
# the agenix CLI tool to know which public keys to use for encryption. See the
# README for more information.
# https://github.com/ryantm/agenix
let
  # Get a system's public key using:
  # > cat /etc/ssh/ssh_host_ed25519_key.pub
  # If you change or add a key, all secrets need to be `agenix --rekey`'ed.
  alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOpQNEmmEe6jr7Mv37ozokvtTSd1I3SmUU1tpCSNTkc root@alpha";
  mu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGP5kEuDiVGeiicxwNUjjrHurWW5EXXxHl8YFRiKzLeX root@mu";
  omega = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvFN4vnqPX31+4/ZJxOJ7/bSUEu2xB6ovezPQjLm13H root@omega";
  sigma = "todo";
  tor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVPxvqwS2NMqqCGBkMmExzdBY5hGLegiOuqPJAOfdKk root@zeta";
  zeta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWiyK636Ys+jRX4ZFByfJMyPIvW4ZsYAITW2fo3VQZx root@zeta";
  # Recovery and management key from Keepass. Used like so:
  # > set AGE_KEY_FILE (mktemp); read -s > $AGE_KEY_FILE
  # > agenix -i $AGE_KEY_FILE -e foo.age
  recovery = "age1rd6hhd724s3r9xe4gfuy38rl0xfu8c7pkuefsrdwqfcknujzecyqz7ldyj";

  all = [alpha mu omega tor zeta];
in
  builtins.mapAttrs (name: value: {publicKeys = value ++ [recovery];}) {
    # Borg backup
    "borg-passphrase-file-omega.age" = [omega];
    "borg-passphrase-file-zeta.age" = [zeta];

    # User passwords
    "users-hashed-password-file.age" = all;

    # Wireguard
    # The preshared key adds an additional layer of symmetric-key crypto to be
    # mixed into the already existing public-key crypto, for post-quantum
    # resistance. Public-keys are generated using `wireguard-vanity-address`.
    "wireguard-preshared-key-file.age" = [alpha omega];
    "wireguard-private-key-file-alpha.age" = [alpha];
    "wireguard-private-key-file-omega.age" = [omega];
  }
