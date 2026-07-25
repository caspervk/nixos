{inputs, ...}: {
  # Atomic secret provisioning for NixOS based on sops.
  # https://github.com/Mic92/sops-nix/
  # https://wiki.nixos.org/wiki/Comparison_of_secret_managing_schemes

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    # Use a (post-quantum secure) key, rather than the (ed25519) SSH host-key
    #
    #   age-keygen -pq --output /nix/sops-key.txt
    #
    age.keyFile = "/nix/sops-key.txt";
    # Don't unnecessarily import SSH keys
    age.sshKeyPaths = [];
    gnupg.sshKeyPaths = [];
    # Don't try to interpret secrets as YAML
    defaultSopsFormat = "binary";
  };
}
