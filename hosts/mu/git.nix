{ home-manager, lib, ... }: {
  home-manager.users.caspervk = {
    programs.git = {
      userEmail = lib.mkForce "vk@magenta.dk";
    };
  };
}
