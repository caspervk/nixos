{...}: {
  imports = [
    ../../overlays
    ../../modules/base
    ../../modules/desktop
    ../../modules/games.nix
    ../../modules/podman.nix
    ./borg.nix
    ./hardware.nix
    ./sway.nix
    ./syncthing.nix
  ];

  # containers.ooniprobe = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   hostAddress = "192.168.100.10";
  #   localAddress = "192.168.100.11";
  #   hostAddress6 = "fc00::1";
  #   localAddress6 = "fc00::2";
  #   config = {
  #     config,
  #     pkgs,
  #     lib,
  #     ...
  #   }: {
  #     networking = {
  #       # Use systemd-resolved inside the container
  #       # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #
  #     services.resolved.enable = true;
  #
  #     system.stateVersion = "24.11";
  #   };
  # };

  networking.hostName = "omega";

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
  system.stateVersion = "25.05"; # Did you read the comment?

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home-manager.users.caspervk.home.stateVersion = "25.05"; # Did you read the comment?
}
