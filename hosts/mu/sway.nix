{...}: {
  home-manager.users.caspervk = {
    wayland.windowManager.sway = {
      config = {
        # swaymsg -t get_outputs
        output = {
          "BOE NE160QDM-NZL Unknown" = {
            mode = "2560x1600@300.000Hz";
            position = "0,100";
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
            output = "BOE NE160QDM-NZL Unknown";
          }
          {
            workspace = "1";
            output = "AOC Q27T1G5 0x000007C8";
          }
          {
            workspace = "4";
            output = "2560x1440@74.968Hz";
          }
        ];
      };
    };
  };

  # Nvidia cringe
  environment.sessionVariables = {
    SWAY_UNSUPPORTED_GPU = "true";
  };
}
