{pkgs, ...}: {
  # NixOS default packages:
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/config/system-path.nix
  environment.systemPackages = [
    pkgs.bandwhich
    pkgs.binutils
    pkgs.dnsutils
    pkgs.fd
    pkgs.file
    pkgs.fzf
    pkgs.git
    pkgs.htop
    pkgs.iputils
    pkgs.jq
    pkgs.lsof
    pkgs.mtr
    pkgs.ncdu
    pkgs.ntp
    pkgs.openssl
    pkgs.pciutils
    pkgs.progress
    pkgs.python3
    pkgs.socat
    pkgs.sqlite-interactive
    pkgs.tcpdump
    pkgs.tmux
    pkgs.traceroute
    pkgs.tree
    pkgs.unar
    pkgs.unzip
    pkgs.usbutils
    pkgs.wget
    pkgs.whois
    pkgs.wireguard-tools
    pkgs.yq-go
  ];
}
