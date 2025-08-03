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
        blame.coloring = "highlightRecent";
        color.blame.highlightRecent = builtins.concatStringsSep "," [
          # 28-step OKLAB gradient
          "#37474f"
          "23 month ago, #3d4d51"
          "22 month ago, #445354"
          "21 month ago, #4b5856"
          "20 month ago, #515e58"
          "19 month ago, #58645a"
          "18 month ago, #5f6a5c"
          "17 month ago, #66705e"
          "16 month ago, #6d7660"
          "15 month ago, #747c62"
          "14 month ago, #7b8364"
          "13 month ago, #838965"
          "12 month ago, #8a8f67"
          "11 month ago, #919569"
          "10 month ago, #999c6a"
          "9 month ago, #a0a26b"
          "8 month ago, #a8a86d"
          "7 month ago, #b0af6e"
          "6 month ago, #b7b56f"
          "5 month ago, #bfbc70"
          "4 month ago, #c7c271"
          "3 month ago, #cfc972"
          "2 month ago, #d7cf73"
          "1 month ago, #dfd674"
          "3 week ago, #e7dd74"
          "2 week ago, #efe375"
          "1 week ago, #f7ea76"
          "1 day ago, #fff176"
        ];
        diff.algorithm = "histogram";
        diff.colorMoved = "default";
        init.defaultBranch = "master";
        pull.rebase = true;
        push.autoSetupRemote = true;
        rebase.autoSquash = true;
        rebase.autoStash = true;
        rebase.updateRefs = true;
      };

      aliases = {
        # https://docs.gitlab.com/ee/user/project/push_options.html
        mr = "push --push-option=merge_request.create --push-option=merge_request.assign='vk'";
      };
    };
  };
}
