{pkgs, ...}: {
  # By default, NixOS uses the latest LTS Linux kernel, which can be a few
  # years old. Use the latest stable kernel instead.
  # https://wiki.nixos.org/wiki/Linux_kernel
  # https://nixos.org/manual/nixos/unstable/index.html#sec-kernel-config
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
