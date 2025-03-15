{
  nixpkgs-unstable,
  pkgs,
  ...
}: {
  # https://wiki.nixos.org/wiki/Steam
  programs.steam = {
    enable = true;
    extraCompatPackages = [
      # Custom Proton. 'Force the use of a specific Steam Play compatibility
      # tool' in each game's properties in Steam.
      # https://github.com/GloriousEggroll/proton-ge-custom
      nixpkgs-unstable.legacyPackages.${pkgs.system}.proton-ge-bin
    ];
  };

  environment.systemPackages = with pkgs; [
    # https://wiki.nixos.org/wiki/Wine
    wineWowPackages.waylandFull
    wineWowPackages.fonts
    winetricks
  ];
}
