{ pkgs, ... }: {
  # https://nixos.wiki/wiki/Fish
  # https://nixos.wiki/wiki/Command_Shell

  environment.systemPackages = with pkgs; [
    fishPlugins.colored-man-pages
    fishPlugins.fzf-fish
    fishPlugins.puffer
    fishPlugins.pure
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fzf_configure_bindings --directory=\cf --git_log=\cg
    '';
  };
  users.defaultUserShell = pkgs.fish;
  environment.shells = with pkgs; [ fish ];
}
