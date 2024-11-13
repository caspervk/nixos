{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=3G" "mode=755"]; # mode=755 so only root can write to those files
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix";
    neededForBoot = true;
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/nix/persist/swapfile";
      size = 4 * 1024; # 4 GiB
    }
  ];

  # Enable hot-adding memory. Otherwise, the machine will be left with 1GB of
  # memory only.
  # https://pve.proxmox.com/wiki/Hotplug_(qemu_disk,nic,cpu,memory)
  # Nix code inspired by (this isn't hyperv):
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/hyperv-guest.nix
  services.udev.packages = lib.singleton (pkgs.writeTextFile {
    name = "proxmox-memory-hotadd-udev-rules";
    destination = "/etc/udev/rules.d/80-hotplug-mem.rules";
    text = ''
      SUBSYSTEM=="memory", ACTION=="add", TEST=="state", ATTR{state}=="offline", ATTR{state}="online"
    '';
  });

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
