{ config, nix-index-database, nixpkgs-unstable, nixpkgs, lib, pkgs, ... }: {
  imports = [
    nix-index-database.nixosModules.nix-index
  ];

  nix = {
    # https://nixos.wiki/wiki/Storage_optimization
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than=90d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };

    # The nix registry is used to refer to flakes using symbolic identifiers
    # when running commands such as `nix run nixpkgs#hello`. By default,
    # the global registry from [1] is used, which aliases `nixpkgs` to the
    # nixpkgs-unstable branch. We overwrite the default global `nixpkgs`
    # registry with one which refers to the same nixpkgs as the rest of
    # the system, aligning it with flake.lock.
    # [1] https://github.com/NixOS/flake-registry/blob/master/flake-registry.json
    registry = {
      nixpkgs.flake = nixpkgs;
      nixpkgs-unstable.flake = nixpkgs-unstable;
    };
  };
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    bat
    clang
    curl
    dig
    fd
    fzf
    gcc
    git
    gnumake
    htop
    inetutils
    jq
    magic-wormhole
    ntp
    progress
    pwgen
    python312
    rsync
    sqlite
    tmux
    traceroute
    tree
    unzip
    wget
    xkcdpass
    yq
  ];

  # https://github.com/nix-community/comma
  programs.nix-index-database.comma.enable = true;
  programs.command-not-found.enable = false;

  i18n = {
    defaultLocale = "en_DK.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_DK.UTF-8";
      LC_IDENTIFICATION = "en_DK.UTF-8";
      LC_MEASUREMENT = "en_DK.UTF-8";
      LC_MONETARY = "en_DK.UTF-8";
      LC_NAME = "en_DK.UTF-8";
      LC_NUMERIC = "en_DK.UTF-8";
      LC_PAPER = "en_DK.UTF-8";
      LC_TELEPHONE = "en_DK.UTF-8";
      LC_TIME = "en_DK.UTF-8";
    };
    supportedLocales = lib.mkOptionDefault [
      "da_DK.UTF-8/UTF-8"
    ];
  };

  time = {
    timeZone = "Europe/Copenhagen";
  };
}
