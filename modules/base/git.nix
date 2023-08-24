{ home-manager, ... }: {
  # Git version control system.
  # https://nixos.wiki/wiki/Git

  home-manager.users.caspervk = {
    programs.git = {
      enable = true;
      userName = "Casper V. Kristensen";
      userEmail = "casper@vkristensen.dk";

      # Delta is a syntax-highlighting pager for git, diff, and grep output
      # https://github.com/dandavison/delta
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
