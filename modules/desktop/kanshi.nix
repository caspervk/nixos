{ home-manager, lib, pkgs, ... }: {
  # https://nix-community.github.io/home-manager/options.html

  home-manager.users.caspervk = {
    services.kanshi = {
      enable = true;
      profiles = {
        # Output names ("criteria") from `swaymsg -t get_outputs`.
        home.outputs = [
          {
            criteria = "ASUSTek COMPUTER INC ROG XG27AQ M3LMQS370969";
            mode = "2560x1440@144Hz";
            position = "0,0";
            adaptiveSync = true;
          }
          {
            criteria = "BNQ BenQ XL2411Z SCD06385SL0";
            mode = "1920x1080@144Hz";
            position = "2560,0";
          }
        ];
      };
    };
  };
}
