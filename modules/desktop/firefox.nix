{ pkgs, ... }: {
  # https://nixos.wiki/wiki/Firefox

  environment.systemPackages = with pkgs; [
    firefox-wayland
  ];
}
