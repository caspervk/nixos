{ home-manager, home-manager-unstable, ... }: {
  # ripgrep isn't in Home Manager v23.05

  home-manager.users.caspervk = {
    imports = [ "${home-manager-unstable}/modules/programs/ripgrep.nix" ];
  };
}
