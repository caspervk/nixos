{...}: {
  # https://github.com/golang/go/issues/68412
  systemd.services.nix-daemon.environment.GOPROXY = "https://goproxy.io";
  systemd.services.nixos-upgrade.environment.GOPROXY = "https://goproxy.io";
}
