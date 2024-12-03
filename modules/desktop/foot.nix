{...}: {
  # Terminal emulator
  # https://codeberg.org/dnkl/foot
  programs.foot = {
    enable = true;
    # https://man.archlinux.org/man/foot.ini.5.en
    settings = {
      main = {
        font = "monospace:size=10.25";
        letter-spacing = "1";
      };
      scrollback = {
        lines = 10000;
      };
      colors = {
        # https://alacritty.org/config-alacritty.html
        foreground = "d8d8d8";
        background = "181818";
        regular0 = "181818"; # black
        regular1 = "ac4242"; # red
        regular2 = "90a959"; # green
        regular3 = "f4bf75"; # yellow
        regular4 = "6a9fb5"; # blue
        regular5 = "aa759f"; # magenta
        regular6 = "75b5aa"; # cyan
        regular7 = "d8d8d8"; # white
        bright0 = "6b6b6b"; # black
        bright1 = "c55555"; # red
        bright2 = "aac474"; # green
        bright3 = "feca88"; # yellow
        bright4 = "82b8c8"; # blue
        bright5 = "c28cb8"; # magenta
        bright6 = "93d3c3"; # cyan
        bright7 = "f8f8f8"; # white
        dim0 = "0f0f0f"; # black
        dim1 = "712b2b"; # red
        dim2 = "5f6f3a"; # green
        dim3 = "a17e4d"; # yellow
        dim4 = "456877"; # blue
        dim5 = "704d68"; # magenta
        dim6 = "4d7770"; # cyan
        dim7 = "8e8e8e"; # white
      };
      key-bindings = {
        # HOW is this not the default?
        scrollback-home = "Shift+Home";
        scrollback-end = "Shift+End";
        # Pipe last command's output to the clipboard. Requires fish
        # integration, configured in modules/base/fish.nix.
        pipe-command-output = "[wl-copy] Control+Shift+g";
      };
    };
  };
}
