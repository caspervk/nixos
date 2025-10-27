{
  lib,
  pkgs,
  ...
}: {
  # https://wiki.nixos.org/wiki/Sway

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
            repeat_delay = "200"; # default 250
            repeat_rate = "50"; # default 25
            # Disable Caps Lock to make it useful for push-to-talk instead.
            # https://git.caspervk.net/caspervk/wayland-push-to-talk
            xkb_options = "caps:none";
          };
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enable";
            dwt = "disabled"; # don't disable-while-typing
          };
          "1133:50509:Logitech_USB_Receiver" = {
            accel_profile = "flat";
            pointer_accel = "0.35"; # pointer SPEED, not acceleration
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
        defaultWorkspace = "workspace number 1";
        keybindings = lib.mkOptionDefault {
          # Menu
          "Mod4+backspace" = "exec rofi -show drun";
          "Mod4+p" = "exec clipman pick -t rofi";
          "Mod4+o" = "exec rofimoji --action=copy --skin-tone=neutral";

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
          "9" = [{app_id = "spotify";}];
        };
        floating = {
          criteria = [
            {app_id = "org.keepassxc.KeePassXC";}
            {app_id = "com.saivert.pwvucontrol";}
            {app_id = "wdisplays";}
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
        terminal = "foot";
        bars = [{command = "${pkgs.waybar}/bin/waybar";}];
      };

      # Execute sway with required environment variables for GTK applications
      wrapperFeatures = {
        gtk = true;
      };
    };

    # https://github.com/Alexays/Waybar/wiki/Configuration
    # https://github.com/Alexays/Waybar/blob/master/resources/config
    programs.waybar = let
      # It isn't possible to extend the default Waybar config in Home
      # Manager; as soon as any setting is defined it overwrites the entire
      # default configuration. To combat  this, we parse the default config
      # into Nix and merge it with our changes.
      mkDefaultConfig = pkgs.stdenv.mkDerivation {
        name = "waybarDefaultConfig";
        src = "${pkgs.waybar}/etc/xdg/waybar";
        installPhase = ''
          # JSON isn't valid if it contains comments
          ${pkgs.python3Packages.json5}/bin/pyjson5 --as-json config.jsonc > $out
        '';
      };
      defaultConfig = builtins.fromJSON (lib.readFile "${mkDefaultConfig}");
    in {
      enable = true;
      settings = {
        bar = lib.mkMerge [
          defaultConfig
          {
            modules-right = lib.mkForce ["tray" "wireplumber" "backlight" "network" "battery" "clock"];
            wireplumber = {
              on-click = "pwvucontrol";
            };
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
                format = {
                  months = "<span color='#35b9ab'><b>{}</b></span>";
                  weekdays = "<span color='#21a4df'><b>{}</b></span>";
                  # https://github.com/Alexays/Waybar/issues/2827
                  weeks = "<span color='#73ba25'><b>{:%V}</b></span>";
                  days = "<span color='#35b9ab'>{}</span>";
                  today = "<span color='#35b9ab' background='#173f4f'><b>{}</b></span>";
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
    services.swayidle = let
      lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
      outputOff = "${pkgs.sway}/bin/swaymsg 'output * power off'";
      outputOn = "${pkgs.sway}/bin/swaymsg 'output * power on'";
      suspend = "${pkgs.systemd}/bin/systemctl suspend";
    in {
      enable = true;
      events = [
        {
          event = "lock";
          command = lock;
        }
        {
          event = "before-sleep";
          command = lock;
        }
      ];
      timeouts = [
        {
          timeout = 60 * 60 * 1;
          command = outputOff;
          resumeCommand = outputOn;
        }
        {
          timeout = 60 * 60 * 4;
          command = suspend;
        }
      ];
    };

    # https://github.com/emersion/mako
    services.mako = {
      enable = true;
      settings = {
        backgroundColor = "#31447f";
        borderColor = "#31447f";
        progressColor = "#3bacf0";
      };
    };

    # https://wiki.nixos.org/wiki/Cursor_Themes
    home.pointerCursor = {
      package = pkgs.catppuccin-cursors.latteLight;
      name = "catppuccin-latte-light-cursors";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
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

  # https://wiki.nixos.org/wiki/Fonts
  fonts = {
    packages = with pkgs; [
      font-awesome # waybar uses Font Awesome icons directly
      # Nerd Fonts patches glyph icons, such as from Font Awesome, into existing fonts
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      emoji = ["Noto Color Emoji"];
      monospace = ["JetBrainsMonoNL Nerd Font"]; # NL = NoLigatures
      sansSerif = ["Noto Sans"];
      serif = ["Noto Serif"];
    };
    fontDir.enable = true;
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    wireplumber # pipewire (wpctl)
    pwvucontrol # pipewire volume control
    playerctl # media control cli for keybinds
    slurp # wayland region selector
    sway-contrib.grimshot # screenshot
    wf-recorder # screen record; wf-recorder -g (slurp) -f recording.mp4
    wdisplays # gui for ad-hoc display configuration
    wl-clipboard # wl-copy/wl-paste commands
    wl-mirror # screen mirroing; wl-mirror (slurp -f%o -o)
    wtype # xdotool for wayland
  ];

  # RealtimeKit is a D-Bus system service that allows user processes to gain
  # realtime scheduling priority on request. It is intended to be used as a
  # secure mechanism to allow real-time scheduling to be used by normal user
  # processes.
  security.rtkit.enable = true;
  # NixOS automatically allows PipeWire real-time scheduling -- allow it for
  # any user process as per the Sway wiki.
  # https://github.com/NixOS/nixpkgs/blob/c45b06d8d908c243f28829998fa403fa501b855e/nixos/modules/services/desktops/pipewire/pipewire.nix#L436-L456
  # https://wiki.nixos.org/wiki/Sway#Inferior_performance_compared_to_other_distributions
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 95;
    }
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
