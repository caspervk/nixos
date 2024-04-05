{home-manager, ...}: {
  # https://nixos.wiki/wiki/Virt-manager

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Make virt-manager use QEMU/KVM by default
  home-manager.users.caspervk = {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };

  # Allow our user to use libvird
  users.groups.libvirtd.members = ["caspervk"];

  # Persist libvirt data
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/libvirt";
        user = "root";
        group = "root";
        mode = "0755";
      }
    ];
  };
}
