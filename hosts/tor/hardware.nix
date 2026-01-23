{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];

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
    options = ["umask=077"];
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
