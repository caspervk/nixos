{
  lib,
  pkgs,
  ...
}: {
  # Fish is a Unix shell with a focus on interactivity and usability. Fish is
  # designed to give the user features by default, rather than by
  # configuration.
  # https://wiki.nixos.org/wiki/Fish
  # https://wiki.nixos.org/wiki/Command_Shell

  programs.fish = {
    enable = true;
    shellAliases = {
      # Read system manual pages using bat as the manual page formatter
      # https://github.com/eth-p/bat-extras/blob/master/doc/batman.md
      "man" = lib.getExe pkgs.bat-extras.batman;
    };
    interactiveShellInit =
      # fish
      ''
        # Allows 's foo bar' for 'nix shell nixpkgs#foo nixpkgs#bar'
        function s --wraps 'nix shell'
          nix shell nixpkgs#$argv
        end

        # fzf: use ctrl+f to list files
        fzf_configure_bindings --directory=\cf
      '';
  };

  # Installing a fish plugin automatically enables it
  environment.systemPackages = with pkgs; [
    fishPlugins.autopair
    fishPlugins.fzf-fish
    fishPlugins.pure
  ];

  # Set fish as the default shell system-wide
  users.defaultUserShell = pkgs.fish;

  # Add fish to the list of permissible login shells for user accounts
  environment.shells = with pkgs; [fish];

  # Enabling fish in both NixOS and home manager is required to pick up
  # completions and environment variables set by NixOS nixpkgs _and_ home
  # manager modules at the same time. As a test, the environment variables from
  # $ nix repl
  # > :lf .
  # > :p nixosConfigurations.omega.config.home-manager.users.caspervk.home.sessionVariables
  # > :p nixosConfigurations.omega.config.home-manager.users.caspervk.home.sessionVariablesExtra
  # should be available in the desktop environment's shell. See
  # https://nix-community.github.io/home-manager/index.html#_why_are_the_session_variables_not_set.
  home-manager.users.caspervk = {
    programs.fish.enable = true;
  };
}
