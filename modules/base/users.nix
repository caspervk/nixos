{
  config,
  inputs,
  ...
}: {
  users = {
    # Don't allow imperative modifications to users (incompatible with impermanence)
    mutableUsers = false;

    users = {
      root = {
        hashedPasswordFile = config.sops.secrets.users-hashed-password-file.path;
      };
      caspervk = {
        isNormalUser = true;
        description = "Casper V. Kristensen";
        hashedPasswordFile = config.sops.secrets.users-hashed-password-file.path;
        extraGroups = [
          "wheel" # allows sudo
          "video" # allows controlling brightness
        ];
        uid = 1000;
      };
    };
  };

  sops.secrets.users-hashed-password-file = {
    sopsFile = "${inputs.secrets}/secrets/users-hashed-password-file.enc";
    mode = "400";
    owner = "root";
    group = "root";
    # https://github.com/Mic92/sops-nix#setting-a-users-password
    neededForUsers = true;
  };
}
