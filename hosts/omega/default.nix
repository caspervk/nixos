{ pkgs, ... }: {
  imports = [
    ../../overlays
    ../../modules/base
    ../../modules/desktop
    ../../modules/syncthing.nix
    ./hardware.nix
    ./borg.nix
    ./network.nix
    ./sway.nix
  ];

  systemd.services.qbittorrent = {
    description = "qBittorrent service";
    documentation = [ "man:qbittorrent-nox(1)" ];
    wantedBy = [ "multi-user.target" ];
    wants = [ "multi-user.target" ];
    after = [ "network-online.target" "nss-lookup.target" ];
    serviceConfig = {
      Type = "exec";
      User = "caspervk";
      Group = "users";
      ExecStart = pkgs.writers.writeBash "asd" ''
        while true; do ${pkgs.curl}/bin/curl ip.caspervk.net; echo; sleep 1; done
      '';
      RestrictNetworkInterfaces = "wg-sigma-public";
    };
  };

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
  system.stateVersion = "23.11"; # Did you read the comment?

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home-manager.users.caspervk.home.stateVersion = "23.11"; # Did you read the comment?
}
