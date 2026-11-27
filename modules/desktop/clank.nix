{
  config,
  inputs,
  pkgs,
  ...
}: {
  # https://git.caspervk.net/caspervk/clank
  environment.systemPackages = [
    (inputs.clank.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      extraModules = [
        ({...}: {
          imports = [
            "${inputs.clank}/magenta/modules/gitlab.nix"
            "${inputs.clank}/magenta/modules/grafana-logs.nix"
            "${inputs.clank}/magenta/modules/kagi.nix"
            "${inputs.clank}/magenta/modules/redmine.nix"
          ];
          home-manager.users.root = {
            programs.opencode = {
              cli.session.sidebar = "hide";
              settings = {
                providers = {
                  deepseek = {
                    settings = {
                      baseURL = "http://clank-proxy:1634";
                    };
                  };
                  greenpt = {
                    settings = {
                      baseURL = "http://clank-proxy:1689/v1";
                    };
                    models = {
                      "kimi-k3.1-pro" = {
                        name = "Kimi K3.1 Pro";
                        capabilities = {
                          tools = true;
                          input = [
                            "text"
                            "image/jpeg"
                            "image/png"
                            "image/gif"
                            "image/webp"
                            "image/bmp"
                            "image/tiff"
                          ];
                          output = ["text"];
                          reasoning = {
                            supported = true;
                            effort = [
                              "none"
                              "minimal"
                              "low"
                              "medium"
                              "high"
                            ];
                          };
                          structured_output = true;
                          cache.implicit = true;
                        };
                        limit = {
                          context = 1048576;
                          output = 1045000;
                        };
                      };
                    };
                  };
                  zai = {
                    settings = {
                      apiKey = "dummy";
                      baseURL = "http://clank-proxy:1684/api/paas/v4";
                    };
                  };
                };
              };
            };
            programs.claude-code = {
              settings = {
                autoMemoryEnabled = false;
                env = {
                  CLAUDE_CODE_OAUTH_TOKEN = "dummy";
                  ANTHROPIC_BASE_URL = "http://clank-proxy:1666";
                };
              };
            };
          };
        })
      ];
    })
  ];

  home-manager.users.caspervk = {
    config,
    osConfig,
    ...
  }: {
    home.file.".config/clank/Caddyfile" = {
      source = config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.clank-caddyfile.path;
      force = true;
    };
  };

  sops.secrets.clank-caddyfile = {
    sopsFile = "${inputs.secrets}/secrets/clank-caddyfile.enc";
    mode = "0400";
    owner = config.users.users.caspervk.name;
    group = config.users.users.caspervk.group;
  };
}
