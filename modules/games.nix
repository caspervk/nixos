{pkgs, ...}: {
  # https://nixos.wiki/wiki/Lutris
  # https://nixos.wiki/wiki/Steam
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    steam-run
    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
      ];
      extraPkgs = pkgs: [
        # List package dependencies here
      ];
    })
  ];
}
