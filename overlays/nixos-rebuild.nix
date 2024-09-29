{...}: {
  # The Nix daemon's temporary build directory is changed from /tmp/ to
  # /var/tmp in modules/base/nix.nix, but it is only respected by `nix build`,
  # not `nixos-rebuild`.
  # This overlay wraps `nixos-rebuild` to explicitly set TMPDIR=/var/tmp.
  # https://github.com/NixOS/nixpkgs/issues/293114
  nixpkgs.overlays = [
    (final: prev: {
      # `overrideAttrs`, instead of simply overriding the `nixos-rebuild`
      # package, to ensure `nixos-rebuild.override`, which is used in NixOS,
      # works and is overridden.
      # https://wiki.nixos.org/wiki/Nix_Cookbook#Wrapping_packages
      # TODO: There must be a better way to do this?
      nixos-rebuild = prev.nixos-rebuild.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [prev.makeWrapper];
        postInstall =
          oldAttrs.postInstall
          + ''
            wrapProgram $out/bin/nixos-rebuild \
              --set TMPDIR /var/tmp
          '';
      });
    })
  ];
}
