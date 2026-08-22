{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.azure-cli
    pkgs.bitwarden-cli
    (pkgs.google-cloud-sdk.withExtraComponents [
      pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    pkgs.k9s
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.poetry
    pkgs.pre-commit
    # Hydra doesn't build docs for old versions
    (builtins.removeAttrs pkgs.python311 ["doc"])
    pkgs.sops
  ];

  home-manager.users.caspervk = {
    programs.fish.shellAliases = {
      sm = "bw get totp e2be31fb-135f-4b28-88cd-b094000ddb67 | wl-copy; gcloud --project magenta-os2mo-production compute ssh --tunnel-through-iap saltmaster";
    };
  };
}
