{
  description = "NixOS system";

  inputs = {
    secrets = {
      url = "git+ssh://git@git.caspervk.net/caspervk/nixos-secrets.git";
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-23.11";
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
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs"; # use the same nixpkgs as the system
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
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

    nixosConfigurations = {
      # Home desktop
      omega = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/omega];
      };
      # Laptop
      zeta = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/zeta];
      };
      # Work laptop
      mu = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/mu];
      };
      # Hetzner VPS
      alpha = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/alpha];
      };
      # Home Server
      sigma = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/sigma];
      };
      # Tor relay
      tor = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs; # pass flake inputs to modules
        modules = [./hosts/tor];
      };
    };
  };
}
