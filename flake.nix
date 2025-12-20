{
  description = "NixOS system";

  inputs = {
    secrets = {
      url = "git+ssh://git@git.caspervk.net/caspervk/nixos-secrets.git";
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixos-hardware = {
      # nixos-hardware is a collection of NixOS modules covering hardware
      # quirks. The modules are imported in each hosts' hardware.nix. See
      # https://github.com/NixOS/nixos-hardware/blob/master/flake.nix for
      # a list of available modules.
      url = "github:NixOS/nixos-hardware/master";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs"; # use the same nixpkgs as the system
      inputs.home-manager.follows = "home-manager"; # use the same home-manager as the system
      inputs.darwin.follows = ""; # don't download dawrin dependencies
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs"; # use the same nixpkgs as the system
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs"; # use the same nixpkgs as the system
    };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs"; # use the same nixpkgs as the system
    };
    sortseer = {
      url = "git+https://git.caspervk.net/caspervk/sortseer.git";
      inputs.nixpkgs.follows = "nixpkgs"; # use the same nixpkgs as the system
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    # https://kamadorueda.com/alejandra/
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.alejandra;

    nixosConfigurations = {
      # Hetzner VPS
      alpha = nixpkgs.lib.nixosSystem {
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/alpha];
      };
      # Hetzner VPS
      delta = nixpkgs.lib.nixosSystem {
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/delta];
      };
      # Work laptop
      mu = nixpkgs.lib.nixosSystem {
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/mu];
      };
      # Home desktop
      omega = nixpkgs.lib.nixosSystem {
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/omega];
      };
      # Home Server
      sigma = nixpkgs.lib.nixosSystem {
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/sigma];
      };
      # Tor relay
      tor = nixpkgs.lib.nixosSystem {
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/tor];
      };
      # Laptop
      zeta = nixpkgs.lib.nixosSystem {
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/zeta];
      };
    };
  };
}
