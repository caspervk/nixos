{...}: {
  # Running containers without /bin/sleep (such as nixos) requires newer
  # forgejo act runner. See https://codeberg.org/forgejo/forgejo/issues/2611.
  nixpkgs.overlays = [
    (final: prev: {
      forgejo-actions-runner = prev.callPackage "${prev.path}/pkgs/development/tools/continuous-integration/forgejo-actions-runner" {
        buildGoModule = args:
          prev.buildGoModule (args
            // rec {
              version = "3.4.1";

              src = prev.fetchFromGitea {
                domain = "codeberg.org";
                owner = "forgejo";
                repo = "runner";
                rev = "v${version}";
                hash = "sha256-c8heIHt+EJ6LnZT4/6TTWd7v85VRHjH72bdje12un4M=";
              };
              vendorHash = "sha256-FCCQZdAYRtJR3DGQIEvUzv+1kqvxVTGkwJwZSohq28s=";
            });
      };
    })
  ];
}
