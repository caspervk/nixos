{ home-manager, lib, pkgs, ... }: {
  # https://nixos.wiki/wiki/Sway

  # Polkit is required to configure sway with home-manager
  security.polkit.enable = true;

  home-manager.users.caspervk = {
    wayland.windowManager.sway = {
      enable = true;
      # Execute sway with required environment variables for GTK applications
      wrapperFeatures = {
        gtk = true;
      };
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
            accel_profile = "flat";
            pointer_accel = "0.5"; # pointer SPEED, not acceleration
          };
        };
        output = {
          "*" = {
            bg = "${./img/background.png} fill";
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

          # Media
          "XF86AudioPlay" = "exec 'playerctl play-pause'";
          "XF86AudioNext" = "exec 'playerctl next'";
          "XF86AudioPrev" = "exec 'playerctl previous'";
        };
        focus = {
          followMouse = "no";
        };
        terminal = "alacritty";
        workspaceAutoBackAndForth = true;
        bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];
      };
    };

    # https://github.com/Alexays/Waybar/wiki/Configuration
    # https://github.com/Alexays/Waybar/blob/master/resources/config
    programs.waybar =
      let
        mkDefaultConfig = pkgs.stdenv.mkDerivation {
          name = "waybarDefaultConfig";
          src = "${pkgs.waybar}/etc/xdg/waybar";
          installPhase = ''
            # JSON isn't valid if it contains comments
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

    # https://github.com/swaywm/swaylock
    programs.swaylock = {
      enable = true;
      settings = {
        image = "${./img/lockscreen.png}";
      };
    };

    # https://github.com/swaywm/swayidle
    services.swayidle =
      let
        lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
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

    # https://sr.ht/~emersion/kanshi/
    services.kanshi = {
      enable = true;
      profiles = {
        # Output names ("criteria") from `swaymsg -t get_outputs`.
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
            position = "2560,0";
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

  # Connect swaylock to PAM. If this isn't done, swaylock needs the suid flag
  security.pam.services.swaylock.text = ''
    auth include login
  '';

  # https://nixos.wiki/wiki/Fonts
  fonts = {
    fonts = with pkgs; [
      # Nerd Fonts patches glyph icons, such as from Font Awesome, into existing fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      font-awesome # waybar uses Font Awesome icons directly
    ];
    fontDir.enable = true; # TODO?
    enableDefaultFonts = true;
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMonoNL Nerd Font" ]; # NL = NoLigatures
    };
  };

  # Audio
  # https://nixos.wiki/wiki/PipeWire
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    pulse.enable = true;
  };

  # `light` command for screen brightness
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty # terminal
    clipman # TODO
    gnome3.adwaita-icon-theme # cursor TODO
    grim # screenshot TODO
    pavucontrol # PulseAudio Volume Control gui
    playerctl # media control cli for keybinds
    pulseaudio # volume control (pactl) for keybinds
    slurp # wayland region selector; for grim(shot)
    wdisplays # gui for ad-hoc display configuration
    wl-clipboard # wl-copy/wl-paste commands
    wl-mirror # screen mirroing; wl-mirror (slurp -f%o -o)
  ];

  # Allow sharing screen
  #xdg.portal.wlr.enable = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };
}
