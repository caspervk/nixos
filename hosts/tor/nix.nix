{...}: {
  # https://github.com/golang/go/issues/68412
  systemd.services.nix-daemon.environment.GOPROXY = "direct";
  systemd.services.nixos-upgrade.environment.GOPROXY = "direct";
}
