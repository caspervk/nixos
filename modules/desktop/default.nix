{ pkgs, ... }: {
  imports = [
    ./firefox.nix
    ./ssh.nix
    ./sway.nix
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
