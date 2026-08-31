{...}: {
  imports = [
    ../../modules/base
    ../../modules/desktop
    ../../modules/games.nix
    ../../modules/podman.nix
    ../../modules/work.nix
    ./borg.nix
    ./hardware.nix
    ./sway.nix
    ./syncthing.nix
  ];

  networking.hostName = "omega";

  # TODO: Baldur's Gate 3
  networking.firewall = {
    allowedUDPPorts = [
      23243
      23244
      23245
      23246
      23247
      23248
      23249
      23250
      23251
      23252
      23253
      23254
      23255
      23256
      23257
      23258
      23259
      23260
      23261
      23262
    ];
  };

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    initrd.luks.devices.crypted.device = "/dev/disk/by-label/crypted";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home-manager.users.caspervk.home.stateVersion = "26.05"; # Did you read the comment?
}
