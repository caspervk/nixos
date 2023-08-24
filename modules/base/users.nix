{ pkgs, ... }: {
  users = {
    # Don't allow imperative modifications to users (incompatible with impermanence)
    mutableUsers = false;

    users = {
      root = {
        # TODO: The passwordfile is manually generated during the initial setup
        # to avoid (hashed) secrets in the public git repo. It should replaced
        # with a proper secret management scheme, such as agenix.
        passwordFile = "/nix/persist/passwordfile";
      };
      caspervk = {
        isNormalUser = true;
        description = "Casper V. Kristensen";
        # TODO: The passwordfile is manually generated during the initial setup
        # to avoid (hashed) secrets in the public git repo. It should replaced
        # with a proper secret management scheme, such as agenix.
        passwordFile = "/nix/persist/passwordfile";
        extraGroups = [
          "networkmanager"
          "wheel" # allows sudo
          "video" # allows controlling brightness
          # todo: systemd-journal, audio, input, power, nix ?
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
