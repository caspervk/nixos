{...}: {
  home-manager.users.caspervk = {
    wayland.windowManager.sway = {
      config = {
        # swaymsg -t get_outputs
        output = {
          "ASUSTek COMPUTER INC ROG XG27AQ M3LMQS370969" = {
            mode = "2560x1440@170.021Hz";
            position = "0,0";
          };
          "BNQ BenQ XL2411Z SCD06385SL0" = {
            mode = "1920x1080@144.001Hz";
            position = "2560,200";
          };
        };
        workspaceOutputAssign = [
          {
            workspace = "1";
            output = "DP-1";
          }
          {
            workspace = "9";
            output = "DP-2";
          }
        ];
      };
    };
  };
}
