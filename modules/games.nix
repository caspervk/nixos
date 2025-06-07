{pkgs, ...}: {
  # https://wiki.nixos.org/wiki/Steam
  programs.steam = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    # https://wiki.nixos.org/wiki/Lutris
    # Lutris uses the system's wine or proton from steam (or downloaded
    # through ProtonPlus/ProtonUp). Check steam if proton is missing.
    lutris
    # https://wiki.nixos.org/wiki/Wine
    winetricks
    wineWowPackages.fonts
    wineWowPackages.waylandFull
  ];
}
