{pkgs, ...}: {
  # Fish is a Unix shell with a focus on interactivity and usability. Fish is
  # designed to give the user features by default, rather than by
  # configuration.
  # https://nixos.wiki/wiki/Fish
  # https://nixos.wiki/wiki/Command_Shell

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Allow jumping between prompts (ctrl+shift+z/x) in foot.
      # https://codeberg.org/dnkl/foot/wiki#jumping-between-prompts
      function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
      end

      # Allow piping last command's output (ctrl+shift+g) in foot.
      # https://codeberg.org/dnkl/foot/wiki#piping-last-command-s-output
      function foot_cmd_start --on-event fish_preexec
        echo -en "\e]133;C\e\\"
      end
      function foot_cmd_end --on-event fish_postexec
        echo -en "\e]133;D\e\\"
      end

      # Allows 's foo bar' for 'nix shell nixpkgs#foo nixpkgs#bar'
      function s --wraps 'nix shell'
        nix shell nixpkgs#$argv
      end

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
