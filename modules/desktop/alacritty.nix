{ home-manager, ... }: {
  # https://wiki.archlinux.org/title/Alacritty

  home-manager.users.caspervk = {
    programs.alacritty = {
      enable = true;
      settings = {
        key_bindings = [
          { key = "Return"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
        ];
      };
    };
  };
}
