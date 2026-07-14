{pkgs, ...}: {
  # Open-source, self-hosted note-taking tool built for quick capture.
  # Markdown-native, lightweight, and fully yours.
  # https://usememos.com/
  services.memos = {
    enable = true;
    # Use newer version to allow disabling link previews
    # https://github.com/usememos/memos/commit/e3e4ae10512f514f71729779b5096d0d591c8cf4
    # TODO: remove override
    package = pkgs.memos.overrideAttrs (prevAttrs: {
      version = "0.29.1-0038295bbc772b38425b6c7f9ca814e4d1e44260";
      src = pkgs.fetchFromGitHub {
        owner = "usememos";
        repo = "memos";
        rev = "0038295bbc772b38425b6c7f9ca814e4d1e44260";
        hash = "sha256-/9WfV3tvt3nzQBAmJFp6YnRrXexw2eIjCggXVUOp+Vo=";
      };
      vendorHash = "sha256-nyUBXPC8nt+7s2jFHohF0PWBGky24ZSXWtSI4XVf2kU=";
      memos-web = prevAttrs.memos-web.overrideAttrs (_: {
        pnpmDeps = prevAttrs.memos-web.pnpmDeps.overrideAttrs (_: {
          outputHash = "sha256-TVB1WkRdqzfZnEe4z75UVfj9t7nO0UdVoWejul9qiIw=";
        });
      });
      # Upstream added a unit test (TestUserWebhookSigningSecretLifecycle) that
      # resolves example.com; the build sandbox has no network.
      doCheck = false;
    });
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/memos";
        user = "memos";
        group = "memos";
        mode = "0750";
      }
    ];
  };
}
