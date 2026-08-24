{
  inputs,
  pkgs,
  ...
}: let
  # TODO: Remove in NixOS 26.11
  voxtype = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.voxtype-onnx;
in {
  # Voice-to-text with push-to-talk for Wayland compositors.
  # https://voxtype.io

  home-manager.users.caspervk = {
    # TODO: Remove in home-manager 26.11
    imports = [
      "${inputs.home-manager-unstable}/modules/services/voxtype.nix"
    ];

    services.voxtype = {
      enable = true;
      # TODO: Remove in NixOS 26.11
      package = voxtype;
      loadModels = [
        "parakeet-tdt-0.6b-v3"
      ];
      wayland.display = "wayland-1";
      settings = {
        engine = "parakeet";
        parakeet = {
          model = "parakeet-tdt-0.6b-v3";
        };
        hotkey = {
          enabled = false; # Use `voxtype record start/stop` from Sway instead
        };
        audio = {
          device = "default";
          sample_rate = 16000;
          max_duration_secs = 60;
        };
        output = {
          mode = "type";
        };
        text = {
          spoken_punctuation = true;
        };
      };
    };
    wayland.windowManager.sway.config = {
      keycodebindings = {
        # 66 = caps lock
        "66" = "exec ${voxtype}/bin/voxtype record start";
        "--release 66" = "exec ${voxtype}/bin/voxtype record stop";
      };
    };
  };
}
