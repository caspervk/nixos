{home-manager, ...}: {
  # Git version control system.
  # https://wiki.nixos.org/wiki/Git

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
        push.autoSetupRemote = true;
        rebase.autoSquash = true;
        rebase.autoStash = true;
        rebase.updateRefs = true;
      };
    };
  };
}
