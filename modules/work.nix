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
    pkgs.sops
  ];
}
