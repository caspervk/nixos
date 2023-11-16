{ home-manager, pkgs, ... }: {
  home-manager.users.caspervk = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins = with pkgs.vimPlugins; [
        kanagawa-nvim # colorscheme
        vim-sleuth # automatic tab width
        vim-surround # surrounding textobjects
        indent-blankline-nvim # indentation guides
        comment-nvim # comment keybinds
        nvim-colorizer-lua # show colours in colours
        leap-nvim # mouse, but its a keyboard
        nvim-treesitter.withAllGrammars # code parser
        nvim-treesitter-refactor # treesitter highlights and refactor keybinds
        nvim-treesitter-textobjects # syntax-aware text objects
        nvim-treesitter-context # context at the top of the screen
        vim-matchup # better %
        nvim-tree-lua # file explorer
        nvim-web-devicons # file icons for nvim-tree
        project-nvim # project management; mostly for nvim-tree
        nvim-dap # debug adapter protocol
        nvim-dap-virtual-text # show variable values in-line
        salt-vim # salt syntax-highlighting
      ];
      extraPackages = with pkgs; [ ];

      extraConfig = builtins.readFile ./config.vim;
      extraLuaConfig = builtins.readFile ./config.lua;
    };
  };
}
