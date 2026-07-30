{...}: {
  home-manager.users.caspervk = {
    wayland.windowManager.sway = {
      config = {
        # swaymsg -t get_outputs
        output = {
          # TODO
          "eDP-1" = {
            mode = "2560x1600@300.000Hz";
            position = "0,0";
          };
          "AOC Q27T1G5 0x000007C8" = {
            mode = "2560x1440@74.968Hz";
            position = "2560,0";
          };
          "AOC Q27T1G5 0x0000080B" = {
            mode = "2560x1440@74.968Hz";
            position = "5120,0";
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
