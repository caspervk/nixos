{ pkgs, ... }: {
  # https://nixos.wiki/wiki/Fish
  # https://nixos.wiki/wiki/Command_Shell

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # fzf: use ctrl+f to list files and ctrl+g to show the git log
      fzf_configure_bindings --directory=\cf --git_log=\cg
    '';
  };

  # Installing a fish plugin automatically enables it
  environment.systemPackages = with pkgs; [
    fishPlugins.colored-man-pages
    fishPlugins.fzf-fish
    fishPlugins.pure
  ];

  # Set fish as the default shell system-wide
  users.defaultUserShell = pkgs.fish;

  # Add fish to the list of permissible login shells for user accounts
  environment.shells = with pkgs; [ fish ];

  # Enabling fish in both NixOS and home manager is required to pick
  # up completions and environment variables set by NixOS nixpkgs _and_
  # home manager modules at the same time.
  # As a test, the environment variables from
  # $ nix repl
  # > :lf .
  # > :p nixosConfigurations.omega.config.home-manager.users.caspervk.home.sessionVariables
  # > :p nixosConfigurations.omega.config.home-manager.users.caspervk.home.sessionVariablesExtra
  # should be available in the desktop environment's shell.
  # See https://nix-community.github.io/home-manager/index.html#_why_are_the_session_variables_not_set.
  home-manager.users.caspervk = {
    programs.fish.enable = true;
  };
}
