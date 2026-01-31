{...}: {
  # https://wiki.nixos.org/wiki/Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    input = {
      General = {
        # Allow input connections from non-bonded devices. Required for
        # PlayStation 3 DualShock controller support:
        #  - Open "Bluetooth Manager"/`blueman-manager`.
        #  - Connect PS3 Controller using USB.
        #  - Click "Allow Always" in blueman.
        #  - Disconnect USB.
        #  - Test using `evtest-qt`.
        ClassicBondedOnly = false;
      };
    };
  };
  # Bluetooth GUI
  services.blueman.enable = true;

  # Persist paired devices
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/bluetooth";
        user = "root";
        group = "root";
        mode = "0700";
      }
    ];
  };
}
