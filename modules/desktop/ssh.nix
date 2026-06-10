{...}: {
  # https://nix-community.github.io/home-manager/options.html

  home-manager.users.caspervk = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false; # will become the default in the future
      settings = {
        "*" = {
          # ControlMaster enables the sharing of multiple sessions over a
          # single network connection. When enabled, additional sessions to the
          # same host will reuse the master session's connection rather than
          # initiating a new one. This is especially useful when using SCP.
          ControlMaster = "yes";
          # ISPs in Denmark prefer the simplicity of CG-NAT and stateful
          # firewalls to the mess that is IPv6. Force keepalive packets to
          # avoid sessions dying. See
          # https://news.ycombinator.com/item?id=25737611.
          ServerAliveInterval = 25;
          # Add ssh keys to the agent the first time we unlock them so we don't
          # have to type the password all the time.
          AddKeysToAgent = "yes";
        };
      };
    };
  };

  programs.ssh = {
    startAgent = true;
  };
}
