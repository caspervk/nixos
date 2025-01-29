{pkgs, ...}: {
  # https://wiki.nixos.org/wiki/Steam
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    # https://wiki.nixos.org/wiki/Wine
    wineWowPackages.waylandFull
    wineWowPackages.fonts
    winetricks
  ];
}
