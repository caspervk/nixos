{...}: {
  # Git version control system.
  # https://wiki.nixos.org/wiki/Git

  home-manager.users.caspervk = {
    programs.git = {
      enable = true;
      settings = {
        alias = {
          # Push and create GitLab merge request
          # https://docs.gitlab.com/topics/git/commit/#push-options
          mr = "push --push-option=merge_request.create --push-option=merge_request.assign='vk'";
          # Safer force push: refuse to overwrite the remote if it has commits
          # we haven't seen or integrated.
          pushf = "push --force-with-lease --force-if-includes";
        };
        blame = {
          # Highlight more recent changes like in JetBrains IDEs
          coloring = "highlightRecent";
        };
        branch = {
          # Only set up upstream tracking for a new branch when it branches off
          # a remote-tracking branch of the same name.
          autoSetupMerge = "simple";
          # Sort branches by most recently committed to
          sort = "-committerdate";
        };
        checkout = {
          # Assume origin when a branch exists on multiple remotes
          defaultRemote = "origin";
        };
        color.blame.highlightRecent = builtins.concatStringsSep "," [
          # 28-step OKLAB gradient
          "#37474f"
          "23 months ago, #3d4d51"
          "22 months ago, #445354"
          "21 months ago, #4b5856"
          "20 months ago, #515e58"
          "19 months ago, #58645a"
          "18 months ago, #5f6a5c"
          "17 months ago, #66705e"
          "16 months ago, #6d7660"
          "15 months ago, #747c62"
          "14 months ago, #7b8364"
          "13 months ago, #838965"
          "12 months ago, #8a8f67"
          "11 months ago, #919569"
          "10 months ago, #999c6a"
          "9 months ago, #a0a26b"
          "8 months ago, #a8a86d"
          "7 months ago, #b0af6e"
          "6 months ago, #b7b56f"
          "5 months ago, #bfbc70"
          "4 months ago, #c7c271"
          "3 months ago, #cfc972"
          "2 months ago, #d7cf73"
          "1 months ago, #dfd674"
          "3 weeks ago, #e7dd74"
          "2 weeks ago, #efe375"
          "1 weeks ago, #f7ea76"
          "1 day ago, #fff176"
        ];
        commit = {
          # Show the whole commit diff in the commit message editor
          verbose = true;
        };
        diff = {
          # Make diffs more readable
          algorithm = "histogram";
          # Use different colours to highlight moved lines
          colorMoved = "default";
        };
        fetch = {
          # Automatically delete remote-tracking branches that no longer exist
          # on the remote.
          prune = true;
        };
        init = {
          defaultBranch = "master"; # TODO
        };
        merge = {
          # Make conflicts more readable
          conflictStyle = "zdiff3";
        };
        pull = {
          # Automatically add --rebase
          rebase = true;
        };
        push = {
          # Push new branches without having to --set-upstream
          autoSetupRemote = true;
          # When pushing commits, also push relevant annotated tags
          followTags = true;
        };
        rebase = {
          # Automatically reorder and apply fixup and squash commits during
          # interactive rebase.
          autoSquash = true;
          # Automatically stash uncommitted changes before rebasing, and apply
          # them afterwards.
          autoStash = true;
          # Automatically update other branches that point to the commits being
          # rebased. Makes stacked branches much easier to handle.
          updateRefs = true;
        };
        rerere = {
          # Remember how we resolved conflicts so Git can automatically resolve
          # it the next time it sees the same one.
          enabled = true;
          autoupdate = true;
        };
        tag = {
          # Sort tags by semantic version, rather than lexicographically
          sort = "-version:refname";
        };
        user = {
          name = "Casper V. Kristensen";
          email = "casper@vkristensen.dk";
        };
      };
    };
  };
}
