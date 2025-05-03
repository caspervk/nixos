{pkgs, ...}: {
  # Xfce file manager
  programs.thunar = {
    enable = true;
    plugins = [
      pkgs.xfce.thunar-archive-plugin
      pkgs.xfce.thunar-media-tags-plugin
      pkgs.xfce.thunar-volman
    ];
  };

  # Xfce archive manager
  environment.systemPackages = [
    pkgs.xarchiver
  ];
}
