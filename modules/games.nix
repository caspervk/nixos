{pkgs, ...}: {
  # https://wiki.nixos.org/wiki/Lutris
  # https://wiki.nixos.org/wiki/Steam
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
