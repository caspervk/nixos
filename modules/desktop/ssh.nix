{ home-manager, ... }: {
  # https://nix-community.github.io/home-manager/options.html

  home-manager.users.caspervk = {
    programs.ssh = {
      enable = true;
      # ControlMaster enables the sharing of multiple sessions over a single
      # network connection. When enabled, additional sessions to the same host
      # will reuse the master session's connection rather than initiating a new
      # one. This is especially useful when using SCP.
      controlMaster = "yes";
      matchBlocks = {
        "alpha" = {
          hostname = "alpha.caspervk.net";
          port = 222;
        };
        "delta" = {
          hostname = "delta.caspervk.net";
          port = 222;
        };
        "lambda" = {
          hostname = "lambda.caspervk.net";
          port = 222;
        };
        "sigma" = {
          hostname = "sigma.caspervk.net";
          port = 222;
        };
        "tor" = {
          hostname = "tor.caspervk.net";
          port = 222;
        };
        "git.caspervk.net" = {
          port = 2222;
        };
      };
      extraConfig = ''
        # Add ssh keys to the agent the first time we unlock them so we don't
        # have to type the password all the time.
        AddKeysToAgent yes
      '';
    };
  };

  programs.ssh = {
    startAgent = true;
  };
}
