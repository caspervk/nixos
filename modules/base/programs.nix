{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ascii
    bat
    black
    clang
    curl
    dig
    fd
    file
    fzf
    gcc
    git
    gnumake
    htop
    inetutils
    jq
    magic-wormhole
    ntp
    progress
    pwgen
    python310
    python311
    python312
    rsync
    sqlite
    tmux
    traceroute
    tree
    unzip
    wget
    wireguard-tools
    xkcdpass
    yq
  ];
}
