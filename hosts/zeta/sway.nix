{...}: {
  home-manager.users.caspervk = {
    wayland.windowManager.sway = {
      config = {
        # swaymsg -t get_outputs
        output = {
          "Chimei Innolux Corporation 0x14D2 Unknown" = {
            mode = "1920x1080@60.008Hz";
            position = "0,0";
          };
        };
      };
    };
  };
}
