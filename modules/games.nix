{pkgs, ...}: {
  # https://wiki.nixos.org/wiki/Lutris
  home-manager.users.caspervk = {
    programs.lutris = {
      enable = true;
      extraPackages = [
        # Overlay for monitoring FPS and more
        # https://github.com/flightlessmango/MangoHud
        pkgs.mangohud
        # Adding a Wine version to `winePackages` only registers it as a Wine
        # runner, but Lutris needs `wine` to be available in PATH too, it
        # seems. I guess `winePackages` is useful if you need multiple
        # different Wine versions.
        # https://wiki.nixos.org/wiki/Wine
        pkgs.wineWowPackages.fonts
        pkgs.wineWowPackages.waylandFull
      ];
      # Register proton as a Wine runner. It *is* possible to define
      # `defaultWinePackage`, but that makes home-manager write to the same
      # file as Lutris does when changing settings in the GUI, and so system
      # activation can fail with a 'would be clobbered'-error.
      protonPackages = [
        pkgs.proton-ge-bin
      ];
    };
  };

  # Gamemode and Gamescope are used by Lutris and require extra capabilities.
  # This creates `security.wrappers`.
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  # https://wiki.nixos.org/wiki/Steam
  programs.steam = {
    enable = true;
  };
}
