{...}: {
  # Delta is a syntax-highlighting pager for git, diff, and grep output
  # https://github.com/dandavison/delta

  home-manager.users.caspervk = {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
      options = {
        line-numbers = true;
        side-by-side = true;
      };
    };
  };
}
