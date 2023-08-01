{ pkgs, ... }: {
  users = {
    # Don't allow imperative modifications to users (incompatible with impermanence)
    mutableUsers = false;
    users = {
      root = {
        passwordFile = "/nix/persist/passwordfile";
      };
      caspervk = {
        isNormalUser = true;
        description = "Casper V. Kristensen";
        passwordFile = "/nix/persist/passwordfile";
        extraGroups = [
          "networkmanager"
          "wheel" # allows sudo
          "video" # allows controlling brightness
          # todo: docker, systemd-journal, audio, input, power, nix ?
        ];
        uid = 1000;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPB/qr63FB0ZqOe/iZGwIKNHD8a1Ud/mXVjQPmpIG7pM caspervk@omega"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII71DKQziktCkyMAmL25QKRK6nG2uJDkQXioIZp5JkMZ caspervk@zeta"
        ];
        packages = with pkgs; [ ];
      };
    };
  };
}
