{ home-manager, lib, pkgs, ... }: {
  # https://nixos.wiki/wiki/Sway

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Polkit is required to configure sway with home-manager
  security.polkit.enable = true;

  home-manager.users.caspervk = {
    wayland.windowManager.sway = {
      enable = true;
      config = {
        # swaymsg -t get_inputs
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
          "TODO" = {
            accel_profile = "flat";
            pointer_accel = "0.4"; # pointer SPEED, not acceleration
          };
          "1133:16489:Logitech_MX_Master_2S" = {
            accel_profile = "flat";
            pointer_accel = "0.1";
          };
        };
        output = {
          "*" = {
            background = "${./img/background.png} fill";
          };
        };
        modifier = "Mod4"; # super
        keybindings = lib.mkOptionDefault {
          # Menu
          "Mod4+backspace" = "exec rofi -show drun";
          "Mod4+p" = "exec clipman pick -t rofi";
          "Mod4+o" = "exec rofi -show emoji";

          # Lock
          "Mod4+Escape" = "exec loginctl lock-session";

          # Screenshot
          "Print" = "exec grimshot copy output";
          "Print+Shift" = "exec grimshot copy area";
          "Print+Control" = "exec grimshot copy window";
          "Print+Alt" = "exec grimshot copy active";

          # Mod+a focuses parent, but there is no way (by default) to focus child
          "Mod4+x" = "focus child";

          # Move workspace between outputs
          "Mod4+Control+Shift+h" = "move workspace to output left";
          "Mod4+Control+Shift+l" = "move workspace to output right";

          # Brightness
          "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

          # Volume
          "XF86AudioRaiseVolume" = "exec 'wpctl set-volume --limit=1.5 @DEFAULT_AUDIO_SINK@ 2%+'";
          "XF86AudioLowerVolume" = "exec 'wpctl set-volume --limit=1.5 @DEFAULT_AUDIO_SINK@ 2%-'";
          "XF86AudioMute" = "exec 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'";

          # Media
          "XF86AudioPlay" = "exec 'playerctl play-pause'";
          "XF86AudioNext" = "exec 'playerctl next'";
          "XF86AudioPrev" = "exec 'playerctl previous'";
        };
        assigns = {
          "8" = [{ class = "WebCord"; }];
          "9" = [{ class = "Spotify"; }];
        };
        floating = {
          criteria = [
            { app_id = "org.keepassxc.KeePassXC"; }
            { app_id = "pavucontrol"; }
            { app_id = "wdisplays"; }
          ];
        };
        focus = {
          # Don't automatically focus hovered windows
          followMouse = false;
          # Don't automatically move the mouse cursor when switching outputs
          mouseWarping = false;
        };
        workspaceAutoBackAndForth = true;
        gaps = {
          # Disable borders on workspaces with a single container
          smartBorders = "no_gaps";
        };
        window = {
          # Don't show unnecessary window titlebars, e.g. when there is only
          # one window on screen. The titlebars will still be shown if tabbing
          # or stacking windows.
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

      # Execute sway with required environment variables for GTK applications
      wrapperFeatures = {
        gtk = true;
      };
    };

    # https://github.com/Alexays/Waybar/wiki/Configuration
    # https://github.com/Alexays/Waybar/blob/master/resources/config
    programs.waybar =
      let
        # It isn't possible to extend the default Waybar config in Home
        # Manager; as soon as any setting is defined it overwrites the entire
        # default configuration. To combat  this, we parse the default config
        # into Nix and merge it with our changes.
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
              modules-right = lib.mkForce [ "tray" "pulseaudio" "backlight" "network" "battery" "clock" ];
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
                  mode-mon-col = 3;
                  weeks-pos = "left";
                  on-scroll = 1;
                  format = {
                    months = "<span color='#ffead3'><b>{}</b></span>";
                    days = "<span color='#ecc6d9'><b>{}</b></span>";
                    weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                    weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                    today = "<span color='#ff6699'><b><u>{}</u></b></span>";
                  };
                };
                actions = {
                  on-click-right = "mode";
                  on-scroll-up = "shift_down";
                  on-scroll-down = "shift_up";
                };
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
            box-shadow: inset 0 3px #FF9E3B;  /* kanagawa roninYellow */
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
          #tray, #pulseaudio, #backlight, #network, #battery, #clock {
            background-color: transparent;
            padding: 0 10px;
          }
          #battery.warning:not(.charging) {
            color: #FF9E3B;  /* kanagawa roninYellow */
          }
          #battery.critical:not(.charging) {
            color: #E82424;  /* kanagawa samuraiRed */
          }
          #network.disconnected {
            color: #E82424;  /* kanagawa samuraiRed */
          }
        '';
      };

    # https://github.com/swaywm/swaylock
    programs.swaylock = {
      enable = true;
      settings = {
        # convert background.png -colorspace gray lockscreen.png
        image = "${./img/lockscreen.png}";
      };
    };

    # https://github.com/swaywm/swayidle
    services.swayidle =
      let
        lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
        outputOff = "${pkgs.sway}/bin/swaymsg 'output * power off'";
        outputOn = "${pkgs.sway}/bin/swaymsg 'output * power on'";
        suspend = "${pkgs.systemd}/bin/systemctl suspend";
      in
      {
        enable = true;
        events = [
          { event = "lock"; command = lock; }
          { event = "before-sleep"; command = lock; }
        ];
        timeouts = [
          { timeout = 60 * 20; command = outputOff; resumeCommand = outputOn; }
          { timeout = 60 * 60 * 3; command = suspend; }
        ];
      };

    # https://github.com/emersion/mako
    services.mako = {
      enable = true;
      backgroundColor = "#31447f";
      borderColor = "#31447f";
      progressColor = "#3bacf0";
    };
  };

  # Don't shut down the system when the power key is pressed
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  # Connect swaylock to PAM. If this isn't done, swaylock needs the suid flag
  security.pam.services.swaylock.text = ''
    auth include login
  '';

  # https://nixos.wiki/wiki/Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Nerd Fonts patches glyph icons, such as from Font Awesome, into existing fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      font-awesome # waybar uses Font Awesome icons directly
    ];
    fontDir.enable = true; # TODO?
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMonoNL Nerd Font" ]; # NL = NoLigatures
    };
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    gnome3.adwaita-icon-theme # cursor TODO
    pavucontrol # PulseAudio Volume Control gui
    playerctl # media control cli for keybinds
    slurp # wayland region selector
    sway-contrib.grimshot # screenshot
    wdisplays # gui for ad-hoc display configuration
    wl-clipboard # wl-copy/wl-paste commands
    wl-mirror # screen mirroing; wl-mirror (slurp -f%o -o)
    wtype # xdotool for wayland
  ];

  # xdg portal allows applications secure access to resources outside their
  # sandbox through a D-Bus interface. In particular, this allows screen
  # sharing on Wayland via PipeWire and file open/save dialogues in Firefox.
  # https://nixos.org/manual/nixos/stable/index.html#sec-wayland
  # https://wiki.archlinux.org/title/XDG_Desktop_Portal
  # https://mozilla.github.io/webrtc-landing/gum_test.html
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
}
