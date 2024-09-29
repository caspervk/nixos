{
  home-manager,
  home-manager-unstable,
  nixpkgs-unstable,
  ...
}: {
  home-manager.users.caspervk = {
    disabledModules = ["${home-manager}/modules/programs/neovim.nix"];
    imports = ["${home-manager-unstable}/modules/programs/neovim.nix"];
  };
  nixpkgs.overlays = [
    (final: prev: {
      # Home-manager uses the neovim-unwrapped package for the neovim module
      neovim-unwrapped = nixpkgs-unstable.legacyPackages.${prev.system}.neovim-unwrapped;
      vimPlugins = nixpkgs-unstable.legacyPackages.${prev.system}.vimPlugins;
    })
  ];
}
