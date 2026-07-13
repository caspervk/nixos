{
  inputs,
  pkgs,
  ...
}: {
  # https://git.caspervk.net/caspervk/clank
  environment.systemPackages = [
    (inputs.clank.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      extraModules = [
        ({...}: {
          home-manager.users.root = {
            programs.opencode = {
              settings = {
                provider = {
                  deepseek = {
                    options = {
                      baseURL = "http://clank-proxy:1600";
                    };
                  };
                  google = {
                    options = {
                      apiKey = "dummy";
                      baseURL = "http://clank-proxy:1601/v1beta";
                    };
                  };
                  mistral = {
                    options = {
                      apiKey = "dummy";
                      baseURL = "http://clank-proxy:1602/v1";
                    };
                  };
                  scaleway = {
                    options = {
                      baseURL = "http://clank-proxy:1603/v1";
                    };
                  };
                  zai = {
                    options = {
                      baseURL = "http://clank-proxy:1604/api/paas/v4";
                    };
                  };
                };
              };
            };
            programs.claude-code = {
              settings = {
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
    home.file.".config/clank/Caddyfile".source = config.lib.file.mkOutOfStoreSymlink osConfig.age.secrets.clank-caddyfile.path;
  };

  age.secrets.clank-caddyfile = {
    file = "${inputs.secrets}/secrets/clank-caddyfile.age";
    mode = "400";
    owner = "caspervk";
    group = "users";
  };
}
