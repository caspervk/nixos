{ pkgs, home-manager, ... }: {
  # https://nixos.wiki/wiki/Sway
  # https://nix-community.github.io/home-manager/options.html

  home-manager.users.caspervk = {
    wayland.windowManager.sway = {
      enable = true;
      config = {
        assigns = {
          "1: web" = [{ class = "^Firefox$"; }];
        };
        input = {
          "*" = {
            # Keyboard
            xkb_layout = "us";
            xkb_variant = "altgr-intl";

            # Trackpad
            tap = "enabled";
            natural_scroll = "enable";
            dwt = "disabled";  # don't disable-while-typing
          };
        };
        modifier = "Mod4";  # super
        terminal = "alacritty";
        workspaceAutoBackAndForth = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    alacritty
  ];

  # Audio
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    pulse.enable = true;
  };

  # Video
  programs.light.enable = true;  # allows controlling screen brightness

  # Allow sharing screen
  #xdg.portal.wlr.enable = true;
}
