{pkgs, ...}: {
  # NixOS default packages:
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/config/system-path.nix
  environment.systemPackages = with pkgs; [
    bandwhich
    binutils
    dnsutils
    fd
    file
    fzf
    git
    htop
    iputils
    jq
    lsof
    mtr
    ncdu
    ntp
    openssl
    pciutils
    progress
    python3
    python311
    python312
    socat
    sqlite-interactive
    tcpdump
    tmux
    traceroute
    tree
    unar
    unzip
    usbutils
    wget
    whois
    wireguard-tools
    yq-go
  ];
}
