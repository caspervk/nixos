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
      package = nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.jujutsu;
      # https://martinvonz.github.io/jj/latest/config/
      settings = {
        user = {
          name = "Casper V. Kristensen";
          email = "casper@vkristensen.dk";
        };
      };
    };

    # Jujutsu TUI.
    # https://github.com/idursun/jjui
    programs.jjui = {
      enable = true;
    };
  };
}
