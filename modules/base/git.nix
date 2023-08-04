{ home-manager, ... }: {

  home-manager.users.caspervk = {
    programs.git = {
      enable = true;
      userName = "Casper V. Kristensen";
      userEmail = "casper@vkristensen.dk";

      delta = {
        enable = true;
        options = {
          line-numbers = true;
          side-by-side = true;
        };
      };

      extraConfig = {
        diff.colorMoved = "default";
        init.defaultBranch = "master";
        pull.rebase = true;
        rebase.autoSquash = true;
        rebase.autoStash = true;
      };
    };
  };
}
