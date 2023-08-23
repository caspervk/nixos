{ home-manager, lib, pkgs, ... }: {
  # https://github.com/yory8/clipman

  home-manager.users.caspervk = {
    services.clipman = {
      enable = true;
    };

    # The home manager module doesn't use --no-persist, but it is required if you want to copy images
    # https://github.com/yory8/clipman/issues/59
    # https://github.com/nix-community/home-manager/blob/master/modules/services/clipman.nix
    systemd.user.services.clipman = {
      Service = {
        ExecStart = lib.mkForce "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store --no-persist";
      };
    };
  };
}
