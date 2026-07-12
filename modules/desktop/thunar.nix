{pkgs, ...}: {
  # Xfce file manager
  programs.thunar = {
    enable = true;
    plugins = [
      pkgs.thunar-archive-plugin
      pkgs.thunar-media-tags-plugin
      pkgs.thunar-volman
    ];
  };

  # Xfce archive manager
  environment.systemPackages = [
    pkgs.xarchiver
  ];
}
