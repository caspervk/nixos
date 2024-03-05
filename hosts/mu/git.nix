{
  home-manager,
  lib,
  ...
}: {
  home-manager.users.caspervk = {
    programs.git = {
      userEmail = lib.mkForce "vk@magenta.dk";
      aliases = {
        # https://docs.gitlab.com/ee/user/project/push_options.html
        mr = "push --push-option=merge_request.create --push-option=merge_request.assign='vk'";
      };
    };
  };
}
