{
  config,
  pkgs,
  secrets,
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
          # TODO: systemd-journal, audio, input, power, nix ?
        ];
        uid = 1000;
        packages = with pkgs; [];
      };
    };
  };

  age.secrets.users-hashed-password-file = {
    file = "${secrets}/secrets/users-hashed-password-file.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
