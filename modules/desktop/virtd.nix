{pkgs, ...}: {
  # https://wiki.nixos.org/wiki/Libvirt
  # https://wiki.nixos.org/wiki/Virt-manager

  # Enable libvirtd service
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        # Enable UEFI support
        ovmf.packages = [pkgs.OVMFFull.fd];
        # Enable TPM and secure boot emulation, for Windows 11
        swtpm.enable = true;
      };
    };
  };

  # Enable Virtual Machine Manager GUI
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
