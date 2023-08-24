{ home-manager, ... }: {
  # Terminal emulator
  # https://wiki.archlinux.org/title/Alacritty

  home-manager.users.caspervk = {
    programs.alacritty = {
      enable = true;
      settings = {
        key_bindings = [
          # It's easy to open a new terminal using Mod+Enter in sway, but it
          # always opens in the home directly. This binds Control+Shift+Enter
          # to open a new terminal in the current directory.
          { key = "Return"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
        ];
      };
    };
  };
}
