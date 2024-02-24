{ config, lib, pkgs, modulesPath, ... }: {
  # https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Cloud
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "virtio_gpu" ];
  boot.kernelParams = [ "console=tty" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ]; # mode=755 so only root can write to those files
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

  # Enables DHCP on all ethernet and wireless LAN interfaces.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}

