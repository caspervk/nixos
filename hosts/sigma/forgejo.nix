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
    # https://codeberg.org/forgejo/forgejo/src/branch/forgejo/custom/conf/app.example.ini
    settings = {
      DEFAULT = {
        # Application name, used in the page title.
        APP_NAME = "Git";
      };
      repository = {
        # Default branch name of all repositories.
        DEFAULT_BRANCH = "master";
        # Comma separated list of globally disabled repo units.
        DISABLED_REPO_UNITS = "repo.issues,repo.pulls,repo.wiki,repo.ext_wiki,repo.projects,repo.packages";
        # Disable stars feature.
        DISABLE_STARS = true;
        # Disable repository forking.
        DISABLE_FORKS = true;
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
      # Token from https://git.caspervk.net/admin/actions/runners/
      tokenFile = config.age.secrets.forgejo-runner-token-file.path;
      # Runner labels are used by workflows to define what type of environment
      # they need to be executed in. Each runner declares a set of labels, and
      # the Forgejo server will send it tasks accordingly.
      #
      # A label has the following structure:
      #
      #  <label-name>:<label-type>://<default-image>
      #
      # The label type determines what containerization system will be used to
      # run the workflow. If a label specifies `docker` as its label type, the
      # rest of it is interpreted as the default container image to use if no
      # other is specified.
      #
      # The default container container image can be overridden by a workflow:
      #
      # runs-on: debian-latest
      # container:
      #   image: docker.io/library/alpine:3.20
      #
      # Many workflows designed for GitHub runners assume an image such as
      # `node:20-bullseye`.
      #
      # https://forgejo.org/docs/next/admin/actions/#choosing-labels
      labels = [
        "debian-latest:docker://docker.io/library/debian:stable"
      ];
      # https://forgejo.org/docs/latest/admin/actions/#configuration
      settings = {
        runner = {
          # Default fetch interval is 2s -- no need to spam the server
          fetch_interval = "1m";
        };
        container = {
          # TODO: host networking is required to allow contacting services
          # running on the sigma-public address, such as git.caspervk.net. Why?
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
