{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    azure-cli
    fluxcd
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    kind
    kubectl
    kubernetes-helm
    kustomize
    poetry
    pre-commit
    sops
    terraform
  ];
}
