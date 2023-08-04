{ home-manager, pkgs, ... }: {
  home-manager.users.caspervk = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-sleuth
      ];
      extraPackages = with pkgs; [ ];
      extraConfig = ''
        set number
        set relativenumber

        set scrolloff=3

        set ignorecase
        set smartcase

        set tabstop=4
        set softtabstop=4
        set shiftwidth=4
        set expandtab
      '';
    };
  };
  environment.variables.EDITOR = "vim";
}
