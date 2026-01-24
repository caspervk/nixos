{...}: {
  home-manager.users.caspervk = {
    wayland.windowManager.sway = {
      config = {
        # swaymsg -t get_outputs
        output = {
          "AU Optronics 0xE48D Unknown" = {
            mode = "1920x1080@60.052Hz";
            position = "0,0";
          };
          "AOC Q27T1G5 0x000007C8" = {
            mode = "2560x1440@74.968Hz";
            position = "1920,0";
          };
          "AOC Q27T1G5 0x0000080B" = {
            mode = "2560x1440@74.968Hz";
            position = "4480,0";
          };
        };
        workspaceOutputAssign = [
          {
            workspace = "10";
            output = "eDP-1";
          }
          {
            workspace = "1";
            output = "eDP-7";
          }
          {
            workspace = "4";
            output = "eDP-6";
          }
        ];
      };
    };
  };
}
