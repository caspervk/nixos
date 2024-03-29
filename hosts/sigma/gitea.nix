{
  config,
  pkgs,
  secrets,
  ...
}: {
  # https://forgejo.org/docs/latest/admin/actions/
  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances."default" = {
      enable = true;
      name = "default";
      url = "https://git.caspervk.net";
      # From https://git.caspervk.net/admin/actions/runners/
      tokenFile = config.age.secrets.gitea-actions-runner-token-file.path;
      # The Forgejo runner relies on application containers (Docker, Podman,
      # etc) to execute a workflow in an isolated environment. Labels are used
      # to map jobs' `runs-on` to their runtime environment. Many common
      # actions require bash, git and nodejs, as well as a filesystem that
      # follows the filesystem hierarchy standard.
      labels = [
        "debian-latest:docker://node:20-bullseye"
      ];
      # https://forgejo.org/docs/latest/admin/actions/#configuration
      settings = {
        runner = {
          # Default fetch interval is 2s -- no need to spam the server
          fetch_interval = "5m";
        };
      };
    };
  };

  age.secrets.gitea-actions-runner-token-file = {
    file = "${secrets}/secrets/gitea-actions-runner-token-file.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
