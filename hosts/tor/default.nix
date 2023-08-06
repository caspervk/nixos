{ ... }: {
  imports = [
    ./hardware.nix
    ./tor.nix
    ../../modules/base
    ../../modules/tor
  ];

  networking = {
    hostName = "tor";
    interfaces.ens3.ipv6.addresses = [{
      address = "2a0d:3e83:0001:b284::1";
      prefixLength = 64;
    }];
    defaultGateway6 = {
      # https://www.ssdvps.dk/knowledgebase/18/IPv6-Gateway.html
      address = "2a0d:3e83:1::1";
      interface = "ens3";
    };
  };

  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/vda";
      };
    };
    initrd.luks.devices.crypted.device = "/dev/disk/by-label/crypted";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home-manager.users.caspervk.home.stateVersion = "23.05"; # Did you read the comment?
}
