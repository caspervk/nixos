{ home-manager, ... }: {
  # Gammestep automatically adjusts the screen's colour temperature. It's
  # basically redshift for Wayland.
  # https://gitlab.com/chinstrap/gammastep
  # https://nixos.wiki/wiki/Gammastep

  home-manager.users.caspervk = {
    services.gammastep = {
      enable = true;
      dawnTime = "06:00";
      duskTime = "22:30";
      temperature = {
        day = 6500; # default upstream but not in nixpkgs, neutral
        night = 4500; # default upstream but not in nixpkgs
      };
    };
  };
}
