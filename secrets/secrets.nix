# This file is NOT imported into the NixOS configuration. It is only used for
# the agenix CLI tool to know which public keys to use for encryption. See the
# README for more information.
# https://github.com/ryantm/agenix

let
  # Get a system's public key using:
  # > cat /etc/ssh/ssh_host_ed25519_key.pub
  # If you change or add a key, all secrets need to be `agenix --rekey`'ed.
  alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOpQNEmmEe6jr7Mv37ozokvtTSd1I3SmUU1tpCSNTkc root@alpha";
  mu = "todo";
  omega = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvFN4vnqPX31+4/ZJxOJ7/bSUEu2xB6ovezPQjLm13H root@omega";
  tor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVPxvqwS2NMqqCGBkMmExzdBY5hGLegiOuqPJAOfdKk root@zeta";
  zeta = "todo";
  # Recovery and management key from Keepass. Used like so:
  # > set AGE_KEY_FILE (mktemp); read -s > $AGE_KEY_FILE
  # > agenix -i $AGE_KEY_FILE -e foo.age
  recovery = "age1rd6hhd724s3r9xe4gfuy38rl0xfu8c7pkuefsrdwqfcknujzecyqz7ldyj";

  all = [ alpha omega tor recovery ];
in
builtins.mapAttrs (name: value: { publicKeys = value ++ [ recovery ]; }) {
  "users-hashed-password-file.age" = all;

  # Secret network addresses
  "netdev-51-wg-sigma-p2p-address.age" = [ alpha ];
  "network-wg-sigma-p2p-address.age" = [ omega ];

  ## Wireguard
  # The preshared key adds an additional layer of symmetric-key crypto to be
  # mixed into the already existing public-key crypto, for post-quantum
  # resistance. Public-keys are generated using `wireguard-vanity-address`.
  "wireguard-preshared-key-file.age" = [ alpha omega ];
  "wireguard-private-key-file-alpha.age" = [ alpha ];
  "wireguard-private-key-file-omega.age" = [ omega ];
}
