{
  home-manager,
  lib,
  nixpkgs,
  pkgs,
  ...
}: {
  # Packages useful on a desktop computer which don't require their own module

  environment.systemPackages = with pkgs; [
    firefox-wayland
    gimp
    jetbrains.pycharm-professional
    keepassxc
    (kodi-wayland.withPackages (kodiPackages:
      with kodiPackages; [
        jellyfin
      ]))
    libqalculate
    libreoffice
    mpv
    spotify
    thunderbird
    tor-browser-bundle-bin
    ungoogled-chromium
    vlc
    xdg-utils
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "android-studio-stable"
      "pycharm-professional"
      "spotify"
      "steam"
      "steam-original"
      "steam-run"
      "terraform"
    ];

  home-manager.users.caspervk = {
    home.sessionVariables = {
      # The firefox-wayland package works with wayland without any further
      # configuration, but tor-browser doesn't.
      # TODO: remove when tor browser is based on firefox v121.
      # https://www.mozilla.org/en-US/firefox/121.0/releasenotes/
      MOZ_ENABLE_WAYLAND = 1;
      # https://wiki.archlinux.org/title/Sway#Java_applications
      _JAVA_AWT_WM_NONREPARENTING = 1;
    };
  };
}
