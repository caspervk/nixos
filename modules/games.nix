{pkgs, ...}: {
  # https://wiki.nixos.org/wiki/Lutris
  # https://wiki.nixos.org/wiki/Steam
  # https://wiki.nixos.org/wiki/Wine
  #
  # After install, run
  # > winetricks corefonts d3dx9 d3dx10 dxvk
  # to set up .wine/.

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    dxvk
    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
      ];
      extraPkgs = pkgs: [
        # List package dependencies here
      ];
    })
    wineWowPackages.fonts
    wineWowPackages.waylandFull
    winetricks
  ];
}
