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
}
