{ pkgs, ... }: {
  imports = [
    ./network.nix
    ./ssh.nix
    ./sway.nix
    ./syncthing.nix
  ];

  environment.systemPackages = with pkgs; [
    discord
    firefox-wayland
    keepassxc
    libqalculate
    mpv
    spotify
    tor-browser-bundle-bin
    vlc
  ];

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
}
