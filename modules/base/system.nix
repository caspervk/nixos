{ pkgs, nix-index-database, ... }: {
  imports = [
    nix-index-database.nixosModules.nix-index
  ];

  nix = {
    # https://nixos.wiki/wiki/Storage_optimization
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than=30d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
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
    python3
    pwgen
    ripgrep
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
  };

  time = {
    timeZone = "Europe/Copenhagen";
  };
}
