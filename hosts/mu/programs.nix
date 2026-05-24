{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.azure-cli
    pkgs.bitwarden-cli
    pkgs.fluxcd
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
