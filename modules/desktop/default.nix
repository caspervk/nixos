{ pkgs, ... }: {
  imports = [
    ./firefox.nix
    ./kanshi.nix
    ./network.nix
    ./ssh.nix
    ./sway.nix
    ./syncthing.nix
  ];

  environment.systemPackages = with pkgs; [
    discord
    keepassxc
    mpv
    spotify
    vlc
  ];

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
}
