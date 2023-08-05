{
  description = "NixOS system";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-23.05";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs"; # use the same nixpkgs as the system
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs"; # use the same nixpkgs as the system
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-fmt.html
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

    nixosConfigurations = {
      # Home desktop
      omega = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs; # pass flake inputs to modules
        modules = [
          ./hosts/omega
        ];
      };
      # Laptop
      zeta = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs; # pass flake inputs to modules
        modules = [
          ./hosts/zeta
        ];
      };
      # Tor relay
      tor = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs; # pass flake inputs to modules
        modules = [
          ./hosts/tor
        ];
      };
    };
  };
}
