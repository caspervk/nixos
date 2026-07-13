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
        hashedPasswordFile = config.age.secrets.users-hashed-password-file.path;
      };
      caspervk = {
        isNormalUser = true;
        description = "Casper V. Kristensen";
        hashedPasswordFile = config.age.secrets.users-hashed-password-file.path;
        extraGroups = [
          "wheel" # allows sudo
          "video" # allows controlling brightness
        ];
        uid = 1000;
      };
    };
  };

  age.secrets.users-hashed-password-file = {
    file = "${inputs.secrets}/secrets/users-hashed-password-file.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
