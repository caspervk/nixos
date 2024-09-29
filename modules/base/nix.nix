{
  config,
  nix-index-database,
  nixpkgs-unstable,
  nixpkgs,
  ...
}: {
  imports = [
    nix-index-database.nixosModules.nix-index
  ];

  nix = {
    # https://wiki.nixos.org/wiki/Storage_optimization
    gc = {
      # Automatically run the nix garbage collector, removing files from
      # the store that are not referenced by any generation.
      # https://nixos.org/manual/nix/stable/package-management/garbage-collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      # Automatically optimise the store after each build. Store optimisation
      # reduces nix store space by 25-35% by finding identical files and
      # hard-linking them to each other.
      # https://nixos.org/manual/nix/unstable/command-ref/nix-store/optimise.html
      auto-optimise-store = true;

      # Enable flakes
      experimental-features = ["nix-command" "flakes" "repl-flake"];

      # Timeout connections to the binary cache instead of waiting forever
      connect-timeout = 5;
    };

    # The nix registry is used to refer to flakes using symbolic identifiers
    # when running commands such as `nix run nixpkgs#hello`. By default,
    # `nixpkgs` is an alias of the system's nixpkgs, but no such alias is made
    # for unstable.
    registry = {
      nixpkgs-unstable.flake = nixpkgs-unstable;
    };
  };

  # The system-wide garbage collection service configured above does not know
  # about our user profile.
  home-manager.users.caspervk.nix.gc = {
    inherit (config.nix.gc) automatic options;
    frequency = config.nix.gc.dates;
  };

  # Nix uses /tmp/ (tmpfs) during builds by default. This may cause 'No space
  # left on device' errors with limited system memory or during big builds. Set
  # the Nix daemon to use /var/tmp/ instead. Note that /var/tmp/ should ideally
  # be on the same filesystem as /nix/store/ for faster copying of files.
  # https://github.com/NixOS/nixpkgs/issues/54707
  #
  # NOTE: This does not change the directory for builds during `nixos-rebuild`.
  # See overlays/nixos-rebuild.nix for workaround.
  # https://github.com/NixOS/nixpkgs/issues/293114
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
  };

  # Run unpatched dynamic binaries on NixOS.
  # https://github.com/Mic92/nix-ld
  programs.nix-ld.enable = true;

  # Comma runs software without installing it. Basically it just wraps together
  # `nix shell -c` and `nix-index`. You stick a `,` in front of a command to
  # run it from whatever location it happens to occupy in nixpkgs without
  # really thinking about it.
  # https://github.com/nix-community/comma
  programs.nix-index-database.comma.enable = true;
  programs.command-not-found.enable = false;
}
