{ home-manager, lib, pkgs, ... }: {
  # https://nixos.wiki/wiki/Sway
  # https://nix-community.github.io/home-manager/options.html

  security.polkit.enable = true;

  home-manager.users.caspervk = {
    wayland.windowManager.sway = {
      enable = true;
      config = {
        input = {
          "type:keyboard" = {
            xkb_layout = "us";
            xkb_variant = "altgr-intl";
            repeat_delay = "250";
          };
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enable";
            dwt = "disabled"; # don't disable-while-typing
          };
          "type:pointer" = {
            # pointer_accel = "0.8"; # pointer SPEED, not acceleration
            # accel_profile = "flat";
          };
        };
        modifier = "Mod4"; # super
        keybindings = lib.mkOptionDefault {
          "Mod4+x" = "focus child";
          "Mod4+Escape" = "exec loginctl lock-session";

          # Move workspace between outputs
          "Mod4+Control+Shift+h" = "move workspace to output left";
          "Mod4+Control+Shift+l" = "move workspace to output right";

          # Brightness
          "XF86MonBrightnessUp" = "exec light -A 5";
          "XF86MonBrightnessDown" = "exec light -U 5";

          # Volume
          "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +2%'";
          "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -2%'";
          "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
        };
        terminal = "alacritty";
        workspaceAutoBackAndForth = true;
        bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];
      };
    };

    programs.waybar =
      let
        mkDefaultConfig = pkgs.stdenv.mkDerivation {
          name = "waybarDefaultConfig";
          src = "${pkgs.waybar}/etc/xdg/waybar";
          installPhase = ''
            sed 's#//.*##' config | ${pkgs.jq}/bin/jq > $out
          '';
        };
        defaultConfig = builtins.fromJSON (lib.readFile "${mkDefaultConfig}");
      in
      {
        enable = true;
        settings = {
          bar = lib.mkMerge [
            defaultConfig
            {
              modules-right = lib.mkForce [ "tray" "idle_inhibitor" "pulseaudio" "cpu" "memory" "backlight" "network" "battery" "clock" ];
              battery = {
                states = lib.mkForce {
                  warning = 15;
                  critical = 5;
                };
              };
              clock = {
                interval = 5;
                locale = "da_DK.UTF-8";
                format = "{:%a %e. %b  %H:%M}";
                calendar = {
                  mode = "year";
                  mode-mon-col = 6;
                  weeks-pos = "left";
                };
              };
              backlight = {
                format-icons = lib.mkForce [ "" ];
              };
            }
          ];
        };
      };

    services.swayidle =
      let
        lock = "${pkgs.swaylock}/bin/swaylock --daemonize --color=333333";
      in
      {
        enable = true;
        events = [
          { event = "lock"; command = lock; }
          { event = "before-sleep"; command = lock; }
        ];
        timeouts = [
          { timeout = 600; command = lock; }
        ];
      };
  };

  environment.systemPackages = with pkgs; [
    alacritty
    clipman
    gnome3.adwaita-icon-theme # cursor
    pavucontrol # PulseAudio Volume Control
    pulseaudio # pactl
    swaylock
    wdisplays
    wl-clipboard
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
  programs.light.enable = true; # allows controlling screen brightness

  # Allow sharing screen
  #xdg.portal.wlr.enable = true;

  security.pam.services.swaylock.text = ''
    # PAM configuration file for the swaylock screen locker. By default, it includes
    # the 'login' configuration file (see /etc/pam.d/login)
    auth include login
  '';

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    font-awesome # for waybar
  ];
}
