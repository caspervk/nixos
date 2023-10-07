{ home-manager, ... }: {
  home-manager.users.caspervk = {
    wayland.windowManager.sway = {
      config = {
        # swaymsg -t get_outputs
        output = {
          "AU Optronics 0xE48D Unknown" = {
            mode = "1920x1080@60.052Hz";
            position = "0,0";
          };
        };
      };
    };
  };
}
