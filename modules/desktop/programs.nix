{ home-manager, pkgs, ... }: {
  # Packages useful on a desktop computer which don't require their own module

  environment.systemPackages = with pkgs; [
    firefox-wayland
    keepassxc
    (kodi-wayland.withPackages (kodiPackages: with kodiPackages; [
      jellyfin
    ]))
    libqalculate
    mpv
    spotify
    tor-browser-bundle-bin
    vlc
    webcord # discord
  ];

  home-manager.users.caspervk = {
    home.sessionVariables = {
      # The firefox-wayland package works with wayland without any further
      # configuration, but tor-browser doesn't.
      MOZ_ENABLE_WAYLAND = 1;
    };
  };
}
