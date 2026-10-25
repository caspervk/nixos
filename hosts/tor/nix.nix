{...}: {
  # https://github.com/golang/go/issues/68412
  systemd.services.nix-daemon.environment.GOPROXY = "direct";
}
