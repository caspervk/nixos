{ ... }: {
  # Automatically `nixos-rebuild switch` daily with the latest configuration
  # from git. This overwrites any uncommitted changes in ~/nixos/, which is why
  # it is only enabled on servers. Note that this requires updating flake.lock
  # in the repository periodically (see Containerfile). Alternatively, at the
  # cost of reproducability, add
  # flags = [ "--recreate-lock-file" "--no-write-lock-file" ]
  # to ignore the repository flake.lock and use the latest input versions.
  system.autoUpgrade = {
    enable = true;
    flake = "git+https://git.caspervk.net/caspervk/nixos.git";
  };
}
