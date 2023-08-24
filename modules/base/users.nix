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
          "wheel" # allows sudo
          "video" # allows controlling brightness
          # todo: systemd-journal, audio, input, power, nix ?
        ];
        uid = 1000;
        packages = with pkgs; [ ];
      };
    };
  };
}
