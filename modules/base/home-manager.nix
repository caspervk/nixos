{ config, home-manager, ... }: {
  # https://nix-community.github.io/home-manager/index.html#sec-flakes-nixos-module
  # https://nixos.wiki/wiki/Home_Manager

  imports = [
    home-manager.nixosModules.home-manager
  ];

  home-manager = {
    # Use the same nixpkgs as the system
    useGlobalPkgs = true;

    # Install packages to /etc/profiles instead of $HOME/.nix-profile, not sure why
    useUserPackages = true;

    users.caspervk = {
      # Define the user and path Home Manager should manage
      home = with config.users.users; {
        username = caspervk.name;
        homeDirectory = caspervk.home;
      };

      # Let Home Manager install and manage itself
      programs.home-manager.enable = true;
    };
  };
}
