{ home-manager, ... }: {

  home-manager.users.caspervk = {
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--smart-case"
      ];
    };
  };
}
