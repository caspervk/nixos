{ home-manager, lib, nixpkgs, pkgs, ... }: {
  # Packages useful on a desktop computer which don't require their own module

  environment.systemPackages = with pkgs; [
    firefox-wayland
    gimp
    jetbrains.pycharm-professional
    keepassxc
    (kodi-wayland.withPackages (kodiPackages: with kodiPackages; [
      jellyfin
    ]))
    libqalculate
    libreoffice
    mpv
    spotify
    tor-browser-bundle-bin
    ungoogled-chromium
    vlc
    webcord # discord
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "android-studio-stable"
    "pycharm-professional"
    "spotify"
    "terraform"
  ];

  home-manager.users.caspervk = {
    home.sessionVariables = {
      # The firefox-wayland package works with wayland without any further
      # configuration, but tor-browser doesn't.
      MOZ_ENABLE_WAYLAND = 1;
    };
  };
}
