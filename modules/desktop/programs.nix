{
  lib,
  pkgs,
  ...
}: {
  # Packages useful on a desktop computer which don't require their own module

  environment.systemPackages = [
    pkgs.ascii
    pkgs.aspell
    pkgs.aspellDicts.da
    pkgs.aspellDicts.en
    pkgs.aspellDicts.en-computers
    pkgs.element-desktop
    pkgs.firefox
    pkgs.gimp
    pkgs.hunspell
    pkgs.hunspellDicts.da-dk
    pkgs.hunspellDicts.en-gb-ise
    pkgs.hunspellDicts.en-us
    pkgs.jetbrains.pycharm-oss
    pkgs.keepassxc
    (pkgs.kodi-wayland.withPackages (kodiPackages: [kodiPackages.jellyfin]))
    pkgs.libqalculate
    pkgs.libreoffice
    pkgs.mpv
    pkgs.mumble
    pkgs.pwgen
    pkgs.python311
    pkgs.python312
    pkgs.python313
    pkgs.spotify
    pkgs.thunderbird
    pkgs.tor-browser # .tor\ project/Tor/torrc: ExitNodes {dk}
    pkgs.ungoogled-chromium
    pkgs.vlc
    pkgs.xdg-utils
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
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
