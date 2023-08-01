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
      inputs.nixpkgs.follows = "nixpkgs";  # use the same nixpkgs as the system
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";  # use the same nixpkgs as the system
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # Home desktop
      omega = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;  # pass flake inputs to modules
        modules = [
          ./hosts/omega
        ];
      };
    };
  };
}
