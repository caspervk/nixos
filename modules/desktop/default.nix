{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./clipman.nix
    ./network.nix
    ./ssh.nix
    ./sway.nix
    ./syncthing.nix
  ];

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

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
}
