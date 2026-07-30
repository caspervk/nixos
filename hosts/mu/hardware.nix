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
    (inputs.nixos-hardware + "/common/gpu/nvidia/blackwell")
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-sync
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usbhid" "sdhci_pci"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

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
      size = 32 * 1024; # 32 GiB
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # GPU
  # https://wiki.nixos.org/wiki/NVIDIA
  hardware.nvidia = {
    prime = {
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  # Allow cringe proprietary userspace packages
  nixpkgs.config.allowUnfreePackages = ["nvidia-x11" "nvidia-settings"];

  # Disable cringe gamer RGB
  hardware.tuxedo-drivers.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="leds", KERNEL=="*kbd_backlight*", ATTR{brightness}="0"
    SUBSYSTEM=="leds", KERNEL=="*lightbar*", ATTR{brightness}="0"
  '';
}
