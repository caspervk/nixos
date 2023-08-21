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
            pointer_accel = "0.4"; # pointer SPEED, not acceleration
          };
        };
        output = {
          "*" = {
            bg = "${./img/background.png} fill";
          };
        };
        modifier = "Mod4"; # super
        keybindings = lib.mkOptionDefault {
          # Menu
          "Mod4+backspace" = "exec rofi -show combi";

          # Lock
          "Mod4+Escape" = "exec loginctl lock-session";

          # Mod+a focuses parent, but there is no way (by default) to focus child
          "Mod4+x" = "focus child";

          # Move workspace between outputs
          "Mod4+Control+Shift+h" = "move workspace to output left";
          "Mod4+Control+Shift+l" = "move workspace to output right";

          # Brightness
          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "XF86MonBrightnessDown" = "exec brightnessctl set -5%";

          # Volume
          "XF86AudioRaiseVolume" = "exec 'wpctl set-volume --limit=1.5 @DEFAULT_AUDIO_SINK@ 2%+'";
          "XF86AudioLowerVolume" = "exec 'wpctl set-volume --limit=1.5 @DEFAULT_AUDIO_SINK@ 2%-'";
          "XF86AudioMute" = "exec 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'";

          # Media
          "XF86AudioPlay" = "exec 'playerctl play-pause'";
          "XF86AudioNext" = "exec 'playerctl next'";
          "XF86AudioPrev" = "exec 'playerctl previous'";
        };
        focus = {
          followMouse = "no";
        };
        gaps = {
          smartBorders = "no_gaps";
        };
        window = {
          titlebar = false;
        };
        colors = {
          focused = {
            background = "#31447f";
            border = "#31447f";
            childBorder = "#31447f";
            indicator = "#3bacf0";
            text = "#ffffff";
          };
        };
        terminal = "alacritty";
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
              modules-right = lib.mkForce [ "tray" "idle_inhibitor" "pulseaudio" "backlight" "network" "battery" "clock" ];
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
        # https://github.com/Alexays/Waybar/wiki/Styling
        # https://github.com/Alexays/Waybar/blob/master/resources/style.css
        style = ''
          window#waybar {
            color: white;
            background-color: rgba(0, 0, 0, 0.5);
            border-bottom: 1px solid rgba(0, 0, 0, 0.5);
            transition-duration: 0s;
          }
          #workspaces button {
            color: white;
            box-shadow: inset 0 3px transparent;
            border: none;
            border-radius: 0;
          }
          #workspaces button.focused {
            box-shadow: inset 0 3px #FF9E3B;
            background-color: transparent;
          }
          #workspaces button:hover {
            /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
            background: rgba(0, 0, 0, 0.25);  
            text-shadow: inherit;
          }
          #mode {
              background-color: rgba(255, 255, 255, 0.4);
              border: none;
          }
          #tray, #idle_inhibitor, #pulseaudio, #backlight, #network, #battery, #clock {
            background-color: transparent;
            padding: 0 10px;
          }
        '';
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

    # https://github.com/davatorium/rofi
    # https://github.com/lbonn/rofi (wayland fork)
    # https://wiki.archlinux.org/title/rofi
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      plugins = with pkgs; [
        rofi-emoji
      ];
      theme = "glue_pro_blue";
      extraConfig = {
        modi = "combi";
        combi-modi = "window,drun,emoji";
        show-icons = true;
      };
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

    home.sessionVariables = {
      # The firefox-wayland package works with wayland without any further
      # configuration, but tor-browser doesn't.
      MOZ_ENABLE_WAYLAND = 1;
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

  # The RealtimeKit system services allows user processes to gain realtime scheduling priority
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty # terminal
    brightnessctl
    clipman # TODO
    gnome3.adwaita-icon-theme # cursor TODO
    grim # screenshot TODO
    pavucontrol # PulseAudio Volume Control gui
    playerctl # media control cli for keybinds
    slurp # wayland region selector; for grim(shot)
    wdisplays # gui for ad-hoc display configuration
    wl-clipboard # wl-copy/wl-paste commands
    wl-mirror # screen mirroing; wl-mirror (slurp -f%o -o)
    wtype # xdotool for wayland
  ];

  # xdg portal allows applications secury access to resources outside their sandbox.
  # In particular, this allows screen sharing on Wayland via PipeWire and file open/save dialogues in Firefox.
  # https://wiki.archlinux.org/title/XDG_Desktop_Portal
  # https://mozilla.github.io/webrtc-landing/gum_test.html
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };
}
