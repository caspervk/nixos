{ pkgs, ... }: {
  imports = [
    ./firefox.nix
    ./ssh.nix
    ./sway.nix
  ];

  environment.systemPackages = with pkgs; [
    discord
    keepassxc
  ];

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
}
