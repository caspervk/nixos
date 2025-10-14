{
  config,
  nix-index-database,
  nixpkgs-unstable,
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

    # https://nix.dev/manual/nix/2.24/command-ref/conf-file.html
    settings = {
      # Automatically optimise the store after each build. Store optimisation
      # reduces nix store space by 25-35% by finding identical files and
      # hard-linking them to each other.
      # https://nixos.org/manual/nix/unstable/command-ref/nix-store/optimise.html
      auto-optimise-store = true;

      # Enable flakes
      experimental-features = ["nix-command" "flakes"];

      # Timeout connections to the binary cache instead of waiting forever
      connect-timeout = 5;
    };

    # The nix registry is used to refer to flakes using symbolic identifiers
    # when running commands such as `nix run nixpkgs#hello`. By default,
    # `nixpkgs` is an alias of the system's nixpkgs, but no such alias is made
    # for unstable.
    # https://search.nixos.org/options?show=nixpkgs.flake.setFlakeRegistry
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
