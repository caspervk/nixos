{
  description = "NixOS system";

  # Use `grep _2 flake.lock` to find missing inputs.follows
  inputs = {
    secrets = {
      url = "git+ssh://git@git.caspervk.net/caspervk/nixos-secrets.git";
    };
    nixpkgs = {
      url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
    };
    nixpkgs-unstable = {
      url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    };
    nixos-hardware = {
      # nixos-hardware is a collection of NixOS modules covering hardware
      # quirks. The modules are imported in each hosts' hardware.nix. See
      # https://github.com/NixOS/nixos-hardware/blob/master/flake.nix for
      # a list of available modules.
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs"; # use the same nixpkgs as the system
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.darwin.follows = ""; # don't download dawrin dependencies
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-syndicate = {
      url = "git+https://git.caspervk.net/caspervk/git-syndicate.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sortseer = {
      url = "git+https://git.caspervk.net/caspervk/sortseer.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clank = {
      url = "git+https://git.caspervk.net/caspervk/clank.git?ref=dev"; # TODO
      inputs.nixpkgs.follows = "nixpkgs-unstable"; # use unstable to get latest harnesses
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    # `nix fmt`
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    nixosConfigurations = {
      # Hetzner VPS
      alpha = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;}; # pass flake inputs to modules
        modules = [./hosts/alpha];
      };
      # Hetzner VPS
      delta = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/delta];
      };
      # Work laptop
      mu = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/mu];
      };
      # Home desktop
      omega = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/omega];
      };
      # Home Server
      sigma = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/sigma];
      };
      # Tor relay
      tor = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/tor];
      };
      # Laptop
      zeta = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/zeta];
      };
    };
  };
}
