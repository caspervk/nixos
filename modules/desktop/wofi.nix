{ home-manager, ... }: {
  # Rofi-inspired menu program for Wayland.
  # Used to open programs and view the clipman clipboard history.
  # https://hg.sr.ht/~scoopta/wofi

  home-manager.users.caspervk = {
    programs.wofi = {
      enable = true;
      settings = {
        show = "drun";
        allow_images = true; # show icons
        gtk_dark = true;
        insensitive = true;
        prompt = ""; # hides 'drun' text from the search bar
      };
    };
  };
}
