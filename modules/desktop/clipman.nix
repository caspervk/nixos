{ home-manager, lib, pkgs, ... }: {
  # Clipboard manager. It can help persist clipboard contents after closing an
  # application - which otherwise isn't supported in Wayland - but that breaks
  # rich content copying in general. Therefore, we only use it for clipboard
  # history with wofi as a frontend.
  # https://github.com/yory8/clipman

  home-manager.users.caspervk = {
    services.clipman = {
      enable = true;
    };

    # The home manager module doesn't use --no-persist, but it is required if
    # you want to copy images. See:
    # https://github.com/yory8/clipman/issues/59
    # https://github.com/nix-community/home-manager/blob/master/modules/services/clipman.nix
    systemd.user.services.clipman = {
      Service = {
        ExecStart = lib.mkForce "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store --no-persist";
      };
    };
  };
}
