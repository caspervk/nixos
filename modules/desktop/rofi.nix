{
  home-manager,
  pkgs,
  ...
}: {
  # A window switcher, application launcher and dmenu replacement. Used to open
  # programs, view the clipboard history, and select emojis.
  # https://github.com/davatorium/rofi
  # https://github.com/lbonn/rofi (wayland fork)
  # https://wiki.archlinux.org/title/rofi

  home-manager.users.caspervk = {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      theme = "android_notification";
      extraConfig = {
        modes = "drun,emoji";
        show-icons = true;
      };
      plugins = with pkgs; [
        rofi-emoji
      ];
    };
  };
}
