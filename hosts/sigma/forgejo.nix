{
  config,
  pkgs,
  secrets,
  ...
}: {
  # Forgejo is a lightweight software forge (Git host), with a highlight on
  # being completely free software. It's a fork of Gitea.
  # https://wiki.nixos.org/wiki/Forgejo
  services.forgejo = {
    enable = true;
    # NixOS defaults to forgejo-lts
    package = pkgs.forgejo;
    # Run Forgejo under git:git for better ssh clone urls.
    user = "git";
    group = "git";
    # https://forgejo.org/docs/latest/admin/config-cheat-sheet/
    settings = {
      DEFAULT = {
        # Application name, used in the page title.
        APP_NAME = "Git";
      };
      repository = {
        # Default branch name of all repositories.
        DEFAULT_BRANCH = "master";
        # Comma separated list of globally disabled repo units.
        DISABLED_REPO_UNITS = "repo.issues,repo.ext_issues,repo.pulls,repo.wiki,repo.ext_wiki,repo.projects,repo.packages";
      };
      ui = {
        # Default theme.
        DEFAULT_THEME = "gitea-light";
      };
      server = {
        # Listen address. Defaults to '0.0.0.0'.
        HTTP_ADDR = "localhost";
        # Domain name of the server.
        DOMAIN = "git.caspervk.net";
        # Full public URL of Forgejo server.
        ROOT_URL = "https://git.caspervk.net/";
        # Landing page for unauthenticated users.
        LANDING_PAGE = "/caspervk";
      };
      security = {
        # Cookie lifetime, in days.
        LOGIN_REMEMBER_DAYS = 365;
      };
      service = {
        # Disable registration, after which only admin can create accounts for
        # users.
        DISABLE_REGISTRATION = true;
      };
      session = {
        # Marks session cookies as “secure” as a hint for browsers to only send
        # them via HTTPS. This option is recommend, if Forgejo is being served
        # over HTTPS.
        COOKIE_SECURE = true;
        # Session engine provider.
        PROVIDER = "db";
      };
    };
  };

  # The configured Forgejo user and group is only created automatically if it
  # is left at the default "forgejo". The following is copied from
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/forgejo.nix
  # but with the mkIf removed and "forgejo" substituted for "git".
  users.users = {
    git = {
      home = config.services.forgejo.stateDir;
      useDefaultShell = true;
      group = "git";
      isSystemUser = true;
    };
  };
  users.groups = {
    git = {};
  };

  # https://wiki.nixos.org/wiki/Forgejo
  # https://forgejo.org/docs/latest/admin/actions/
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances."default" = {
      enable = true;
      name = "default";
      url = "https://git.caspervk.net";
      # From https://git.caspervk.net/admin/actions/runners/
      tokenFile = config.age.secrets.forgejo-runner-token-file.path;
      # The Forgejo runner relies on application containers (Docker, Podman,
      # etc) to execute a workflow in an isolated environment. Labels are used
      # to map jobs' `runs-on` to their runtime environment. Many common
      # actions require bash, git and nodejs, as well as a filesystem that
      # follows the filesystem hierarchy standard.
      labels = [
        "debian-latest:docker://docker.io/library/node:20-bullseye"
      ];
      # https://forgejo.org/docs/latest/admin/actions/#configuration
      settings = {
        runner = {
          # Default fetch interval is 2s -- no need to spam the server
          fetch_interval = "1m";
        };
        container = {
          # TODO: host networking is required to allow contacting services
          # running on the sigma-public address, such as git.caspervk.net.
          # We don't need this if we replace Docker with Podman, since that has
          # actual sane networking. Note, however, that the forgejo runner
          # requires a Docker socket. Podman can emulate this, and the runner
          # be configured to use it through
          # `container.docker_host = "unix://podman.sock"`, but we need to figure
          # out how to run a non-root Podman user socket easily in NixOS.
          network = "host";
        };
      };
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/forgejo";
        user = "git";
        group = "git";
        mode = "0750";
      }
    ];
  };

  age.secrets.forgejo-runner-token-file = {
    file = "${secrets}/secrets/forgejo-runner-token-file.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
