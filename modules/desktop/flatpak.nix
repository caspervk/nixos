{ home-manager, ... }: {
  # https://flatpak.org/setup/NixOS
  # https://nixos.wiki/wiki/Flatpak

  services.flatpak.enable = true;

  # Add desktop shortcuts for flatpak applications
  home-manager.users.caspervk = {
    home.sessionVariables = {
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share";
    };
  };

  # Persist flatpaks
  environment.persistence."/nix/persist" = {
    directories = [
      { directory = "/var/lib/flatpak"; user = "root"; group = "root"; mode = "0755"; }
    ];
  };
}
