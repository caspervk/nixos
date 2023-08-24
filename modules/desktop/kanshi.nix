{ home-manager, ... }: {
  # kanshi allows you to define output profiles that are automatically enabled
  # and disabled on hotplug. For instance, this can be used to turn a laptop's
  # internal screen off when docked. This is a Wayland equivalent for tools
  # like autorandr.
  # https://sr.ht/~emersion/kanshi/

  home-manager.users.caspervk = {
    services.kanshi = {
      enable = true;
      profiles = {
        # Output names (criteria) from `swaymsg -t get_outputs`.
        omega.outputs = [
          {
            criteria = "ASUSTek COMPUTER INC ROG XG27AQ M3LMQS370969";
            mode = "2560x1440@144Hz";
            position = "0,0";
            adaptiveSync = false; # seems to flicker
          }
          {
            criteria = "BNQ BenQ XL2411Z SCD06385SL0";
            mode = "1920x1080@144Hz";
            position = "2560,400";
          }
        ];
        zeta.outputs = [
          {
            criteria = "Chimei Innolux Corporation 0x14D2 Unknown";
            mode = "1920x1080@60Hz";
          }
        ];
      };
    };
  };
}
