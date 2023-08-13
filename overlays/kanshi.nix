{ home-manager, home-manager-unstable, nixpkgs-unstable, ... }: {
  # adaptiveSync requires the unstable kanshi nixpkgs and home-manager module

  nixpkgs.overlays = [
    (self: super: {
      kanshi = nixpkgs-unstable.legacyPackages.${super.system}.kanshi;
    })
  ];

  home-manager.users.caspervk = {
    disabledModules = [ "${home-manager}/modules/services/kanshi.nix" ];
    imports = [ "${home-manager-unstable}/modules/services/kanshi.nix" ];
  };
}
