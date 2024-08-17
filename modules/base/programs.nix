{pkgs, ...}: {
  # NixOS default packages:
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/config/system-path.nix
  environment.systemPackages = with pkgs; [
    ascii
    bandwhich
    bat
    binutils
    black
    clang
    dnsutils
    fd
    file
    fzf
    gcc
    git
    gnumake
    htop
    iputils
    jq
    lsof
    magic-wormhole-rs
    mtr
    ncdu
    ntp
    openssl
    pciutils
    postgresql
    progress
    pwgen
    python3
    python310
    python311
    python312
    socat
    sqlite-interactive
    tcpdump
    tmux
    traceroute
    tree
    unzip
    usbutils
    wget
    whois
    wireguard-tools
    yq
  ];
}
