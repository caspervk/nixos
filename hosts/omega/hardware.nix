{
  config,
  lib,
  pkgs,
  modulesPath,
  nixos-hardware,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-cpu-amd-pstate
    nixos-hardware.nixosModules.common-gpu-amd
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-ssd
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  boot.supportedFilesystems = {ntfs = true;};

  # https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=50%" "mode=755"]; # mode=755 so only root can write to those files
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
      size = 16 * 1024; # 16 GiB
    }
  ];

  # Windows
  fileSystems."/mnt/C" = {
    device = "/dev/disk/by-label/C";
    fsType = "ntfs-3g";
    options = ["rw" "uid=1000"];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # GPU
  hardware.amdgpu.amdvlk = {
    enable = true;
    support32Bit.enable = true;
  };
}
