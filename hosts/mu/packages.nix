{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    azure-cli
    fluxcd
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    k9s
    kind
    kubectl
    kubernetes-helm
    kustomize
    poetry
    pre-commit
    sops
    terraform
  ];

  # Allow port-forward to 443
  security.wrappers = {
    k9s = {
      source = "${pkgs.k9s}/bin/k9s";
      owner = "root";
      group = "root";
      capabilities = "cap_net_bind_service+ep";
    };
  };
}
