{
  inputs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  boot.supportedFilesystems = {};

  # https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=50%" "mode=755"]; # mode=755 so only root can write to those files
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
    options = ["x-systemd.device-timeout=infinity"]; # wait indefinitely for unlock
  };

  swapDevices = [
    {
      device = "/nix/persist/swapfile";
      size = 16 * 1024; # 16 GiB
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
