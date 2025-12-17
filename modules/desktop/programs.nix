{
  lib,
  pkgs,
  ...
}: {
  # Packages useful on a desktop computer which don't require their own module

  environment.systemPackages = with pkgs; [
    ascii
    aspell
    aspellDicts.da
    aspellDicts.en
    aspellDicts.en-computers
    element-desktop
    firefox-wayland
    gimp
    hunspell
    hunspellDicts.da-dk
    hunspellDicts.en-gb-ise
    hunspellDicts.en-us
    jetbrains.pycharm-professional
    keepassxc
    (kodi-wayland.withPackages (kodiPackages: [kodiPackages.jellyfin]))
    libqalculate
    libreoffice
    mpv
    mumble
    pwgen
    python311
    python312
    python313
    spotify
    thunderbird
    tor-browser # .tor\ project/Tor/torrc: ExitNodes {dk}
    ungoogled-chromium
    vlc
    xdg-utils
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "pycharm-professional"
      "spotify"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "terraform"
    ];

  home-manager.users.caspervk = {
    home.sessionVariables = {
      # https://wiki.archlinux.org/title/Sway#Java_applications
      _JAVA_AWT_WM_NONREPARENTING = 1;
      # https://wiki.nixos.org/wiki/Wayland
      NIXOS_OZONE_WL = 1;
    };
  };
}
