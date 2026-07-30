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
          home-manager.users.root = {
            programs.opencode = {
              settings = {
                provider = {
                  berget = {
                    options = {
                      baseURL = "http://clank-proxy:1600/v1";
                    };
                  };
                  deepseek = {
                    options = {
                      baseURL = "http://clank-proxy:1601";
                    };
                  };
                  google = {
                    options = {
                      apiKey = "dummy";
                      baseURL = "http://clank-proxy:1602/v1beta";
                    };
                  };
                  mistral = {
                    options = {
                      apiKey = "dummy";
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
    home.file.".config/clank/Caddyfile".source = config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.clank-caddyfile.path;
  };

  sops.secrets.clank-caddyfile = {
    sopsFile = "${inputs.secrets}/secrets/clank-caddyfile.enc";
    mode = "0400";
    owner = config.users.users.caspervk.name;
    group = config.users.users.caspervk.group;
  };
}
