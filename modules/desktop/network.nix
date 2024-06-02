{lib, ...}: {
  networking = {
    # It's a little too much to define every WiFi network declaratively.
    # Instead, we enable NetworkManager and the nmtui interface.
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none"; # see modules/base/network.nix
    };
  };

  # Allow our user to configure the network
  users.groups.networkmanager.members = ["caspervk"];

  # Persist WiFi passwords and other network configuration
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/etc/NetworkManager/system-connections";
        user = "root";
        group = "root";
        mode = "0700";
      }
    ];
  };

  # systemd-networkd-wait-online can timeout and fail if there are no network
  # interfaces available for it to manage. When systemd-networkd is enabled but
  # a different service is responsible for managing the system's internet
  # connection (for example, NetworkManager), this service is unnecessary and
  # can be disabled.
  # https://search.nixos.org/options?channel=24.05&show=systemd.network.wait-online.enable
  systemd.network.wait-online.enable = false;
}
