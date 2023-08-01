{ home-manager, ... }: {
  # # https://nix-community.github.io/home-manager/options.html

  home-manager.users.caspervk = {
    programs.ssh = {
      enable = true;
      matchBlocks = {
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
        "git.caspervk.net" = {
          port = 2222;
        };
      };
    };
  };
}
