{
  nixpkgs-unstable,
  pkgs,
  ...
}: {
  # Jujutsu version control system.
  # https://martinvonz.github.io/jj/
  home-manager.users.caspervk = {
    programs.jujutsu = {
      enable = true;
      package = nixpkgs-unstable.legacyPackages.${pkgs.system}.jujutsu;
      # https://martinvonz.github.io/jj/latest/config/
      settings = {
        user = {
          name = "Casper V. Kristensen";
          email = "casper@vkristensen.dk";
        };
      };
    };
    # TODO: enable in home-manager 25.11
    # programs.jjui = {
    #   enable = true;
    # };
  };
}
