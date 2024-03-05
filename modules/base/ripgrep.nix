{home-manager, ...}: {
  # ripgrep is a line-oriented search tool that recursively searches the
  # current directory for a regex pattern.
  # https://github.com/BurntSushi/ripgrep

  home-manager.users.caspervk = {
    programs.ripgrep = {
      enable = true;
      arguments = [
        # Search case-insensitively by defaylt if the pattern is all lowercase.
        # Use --case-sensitive or -s to override.
        "--smart-case"
      ];
    };
  };
}
