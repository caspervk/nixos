{ config, lib, pkgs, modulesPath, ... }: {
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "ntfs" ];

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
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/nix/persist/swapfile";
      size = 16 * 1024; # 16 GiB
    }
  ];

  # Windows
  fileSystems."/mnt/C" = {
    device = "/dev/disk/by-label/C";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000"];
  };
  fileSystems."/mnt/Backup" = {
    device = "/dev/disk/by-label/Backup";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000"];
  };

  # Enables DHCP on all ethernet and wireless LAN interfaces.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
