{ home-manager, pkgs, ... }: {
  home-manager.users.caspervk = {
    programs.k9s = {
      enable = true;
      settings = {
        k9s = {
          refreshRate = 1;
          logger = {
            tail = 500;
            sinceSeconds = -1;
            textWrap = true;
            showTime = true;
          };
        };
      };
    };
  };
 
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
