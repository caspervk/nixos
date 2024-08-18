{
  nixpkgs-unstable,
  pkgs,
  ...
}: {
  # NixOS
  # https://wiki.nixos.org/wiki/Neovim
  # https://wiki.nixos.org/wiki/Vim
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovim.enable
  # https://github.com/nix-community/nixvim
  #
  # Popular plugins
  # https://neovimcraft.com/
  # https://dotfyle.com/neovim/plugins/top
  # https://github.com/rockerBOO/awesome-neovim
  #
  # Distros
  # https://docs.astronvim.com/
  # https://nvchad.com/docs/
  # https://www.lazyvim.org/
  # https://www.lunarvim.org/docs/
  #
  # Inspiration
  # https://github.com/nvim-lua/kickstart.nvim
  home-manager.users.caspervk = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraLuaConfig =
        /*
        lua
        */
        ''
          -- Use <Space> as the leader key
          vim.g.mapleader = " "

          -- Show (relative) line numbers
          vim.opt.number = true
          vim.opt.relativenumber = true

          -- Highlight the cursor line
          vim.opt.cursorline = true
          vim.opt.cursorlineopt = {"line", "number"}

          -- Don't show the mode ("-- INSERT --") since it's already in the
          -- status line (plugin).
          vim.opt.showmode = false

          -- Preserve undo history across restarts
          vim.opt.undofile = true

          -- Case-insensitive search -- unless a capital letter is used
          vim.opt.ignorecase = true
          vim.opt.smartcase = true

          -- Always show sign column. Avoids buffer jumping left and right on
          -- gitsigns or LSP diagnostics.
          vim.opt.signcolumn = "yes"

          -- Send CursorHold autocommend event after 100ms (instead of 4000ms
          -- by default). Used, among other things, to highlight definitions
          -- with treesitter faster.
          vim.opt.updatetime = 100

          -- Open new splits on the right and below
          vim.opt.splitright = true
          vim.opt.splitbelow = true

          -- Visualise whitespace characters
          vim.opt.list = true
          vim.opt.listchars = { tab="▸ ", trail="·", nbsp="␣" }

          -- Better diffs
          vim.opt.diffopt:append({"linematch:60", "algorithm:patience"})
          vim.opt.fillchars:append({ diff = "░" })

          -- Show search-replace preview live
          vim.opt.inccommand = "split"

          -- Keep a minimum of 10 lines of context above and below the cursor
          vim.opt.scrolloff = 10
          vim.opt.sidescrolloff = 10

          -- Enable spell cheking
          vim.opt.spell = true
          vim.opt.spelllang = {"en", "da"}
          vim.opt.spelloptions = "camel"

          -- Set better defaults for <Tab>. The guess-indent plugin will
          -- automatically detect indentation style and change these.
          vim.opt.tabstop = 4
          vim.opt.softtabstop = 4
          vim.opt.shiftwidth = 4
          vim.opt.expandtab = true

          -- Automatically round indent to multiple of 'shiftwidth'
          vim.opt.shiftround = true

          -- Show statusline at the bottom only, instead of in each window
          vim.opt.laststatus = 3

          -- Move cursor to the first non-blank of the line on CTRL-D, CTRL-U, G,
          -- gg, etc.
          vim.opt.startofline = true

          -- Keep visual selection after indenting
          vim.keymap.set("v", "<", "<gv")
          vim.keymap.set("v", ">", ">gv")

          -- Use CTRL-{JK} to navigate dropdowns, like CTRL-{NP}, in insert and
          -- command mode.
          vim.keymap.set({"c", "i"}, "<C-j>",  "<C-n>")
          vim.keymap.set({"c", "i"}, "<C-k>",  "<C-p>")

          -- Use CTRL-{HJKL} to navigate windows
          vim.keymap.set("n", "<C-h>",  "<C-w><C-h>")
          vim.keymap.set("n", "<C-j>",  "<C-w><C-j>")
          vim.keymap.set("n", "<C-k>",  "<C-w><C-k>")
          vim.keymap.set("n", "<C-l>",  "<C-w><C-l>")

          -- Use <Escape> to clear search highlight. This is normally bound to
          -- CTRL-L, but we use that to navigate windows instead.
          vim.keymap.set("n", "<Esc>", vim.cmd.noh)

          -- Restore cursor position when opening a file
          -- https://github.com/neovim/neovim/issues/16339#issuecomment-1457394370
          vim.api.nvim_create_autocmd('BufRead', {
            callback = function(opts)
              vim.api.nvim_create_autocmd('BufWinEnter', {
                once = true,
                buffer = opts.buf,
                callback = function()
                  local ft = vim.bo[opts.buf].filetype
                  local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
                  if
                    not (ft:match('commit') and ft:match('rebase'))
                    and last_known_line > 1
                    and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
                  then
                    vim.api.nvim_feedkeys([[g`"]], 'nx', false)
                  end
                end,
              })
            end,
          })
        '';
      plugins = with pkgs.vimPlugins; [
        # NeoVim dark colorscheme inspired by the colors of the famous painting
        # by Katsushika Hokusai.
        # https://github.com/rebelot/kanagawa.nvim
        {
          plugin = kanagawa-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("kanagawa").setup({
                commentStyle = { italic = false },
                keywordStyle = { italic = false },
                dimInactive = true,
                colors = {
                  theme = {
                    all = {
                      ui = {
                        -- Don't use a special background for the gutter
                        bg_gutter = "none",
                      },
                    },
                  },
                },
                overrides = function(colors)
                  local theme = colors.theme
                  return {
                    -- Less pronounced cursorline
                    CursorLine = { bg = theme.ui.bg_p1 },
                    -- More pronounced window borders
                    WinSeparator = { fg = theme.ui.nontext },
                    -- Less pronounced indent lines
                    IblIndent = { fg = theme.ui.bg_p2 },
                    IblScope = { fg = theme.ui.whitespace },
                  }
                end,
              })
              vim.cmd("colorscheme kanagawa")
            '';
        }

        # Adds file type icons to Vim plugins.
        # https://github.com/nvim-tree/nvim-web-devicons
        {
          plugin = nvim-web-devicons;
        }

        # Rearrange window layout using sway-like <Ctrl-Shift-{hjkl}> bindings.
        # https://github.com/sindrets/winshift.nvim
        {
          plugin = winshift-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("winshift").setup({})
              vim.keymap.set("n", "<C-S-h>", function() vim.cmd.WinShift("left") end)
              vim.keymap.set("n", "<C-S-j>", function() vim.cmd.WinShift("down") end)
              vim.keymap.set("n", "<C-S-k>", function() vim.cmd.WinShift("up") end)
              vim.keymap.set("n", "<C-S-l>", function() vim.cmd.WinShift("right") end)
            '';
        }

        # Tree sitter is a parsing system that provides improved syntax
        # highlighting compared to the default regex-based grammars built into
        # Vim.
        # https://github.com/nvim-treesitter/nvim-treesitter
        # https://github.com/nvim-treesitter/nvim-treesitter/wiki/Extra-modules-and-plugins
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("nvim-treesitter.configs").setup({
                -- Consistent syntax highlighting
                highlight = {
                  enable = true,
                },
                -- Indentation based on treesitter
                indent = {
                  enable = true,
                },
              })
            '';
        }
        # Refactor module for nvim-treesitter.
        # https://github.com/nvim-treesitter/nvim-treesitter-refactor
        {
          plugin = nvim-treesitter-refactor;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("nvim-treesitter.configs").setup({
                refactor = {
                  -- Highlight definition and usages of the current symbol under
                  -- the cursor.
                  highlight_definitions = {
                    enable = true,
                    -- Don't redraw (blink) highlight when moving cursor inside a word
                    clear_on_cursor_move = false,
                  },
                  -- Renames the symbol under the cursor within the current scope
                  -- (and current file).
                  smart_rename = {
                    enable = true,
                    keymaps = {
                      -- This keymap will be overwritten in LspAttach
                      smart_rename = "grn",
                    },
                  },
                  -- Provides "go to definition" for the symbol under the cursor,
                  -- and lists the definitions from the current file.
                  navigation = {
                    enable = true,
                    keymaps = {
                      -- This keymap will be overwritten in LspAttach
                      goto_definition = "gd",
                    },
                  },
                },
              })
            '';
        }
        # Code context module for nvim-treesitter.
        # https://github.com/nvim-treesitter/nvim-treesitter-context
        {
          plugin = nvim-treesitter-context;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("treesitter-context").setup({
                -- Show one line of context at the top of the screen
                max_lines = 1,
              })
            '';
        }

        # A completion engine plugin for neovim written in Lua. Completion
        # sources are installed from external repositories and "sourced".
        # https://github.com/hrsh7th/nvim-cmp
        {
          plugin = cmp-nvim-lsp;
        }
        {
          plugin = nvim-cmp;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              local cmp = require("cmp")
              cmp.setup({
                snippet = {
                  -- Configuring a snippet engine is required. Configure
                  -- neovom's native one.
                  expand = function(args)
                    vim.snippet.expand(args.body)
                  end,
                },
                mapping = cmp.mapping.preset.insert({
                  -- Use CTRL-{JK} to navigate and CTRL-L to confirm like
                  -- telescope.
                  ["<C-j>"] = cmp.mapping.select_next_item(),
                  ["<C-k>"] = cmp.mapping.select_prev_item(),
                  ["<C-l>"] = cmp.mapping.confirm({ select = true }),
                  -- Scroll documentatiion
                  ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                  ["<C-d>"] = cmp.mapping.scroll_docs(4),
                  -- Close completion menu
                  ["<C-e>"] = cmp.mapping.abort(),
                  -- Manually trigger completion dropdown. This is not
                  -- generally needed because nvim-cmp will display completions
                  -- whenever it has completion options available.
                  ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                  { name = "nvim_lsp" },
                })
              })

              -- Add parentheses after selecting function or method item (nvim-autopairs).
              -- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#add-parentheses-after-selecting-function-or-method-item
              local cmp_autopairs = require("nvim-autopairs.completion.cmp")
              cmp.event:on(
                "confirm_done",
                cmp_autopairs.on_confirm_done()
              )
            '';
        }

        # Language Server Protocol (LSP). LSP facilitates features like
        # go-to-definition, find references, hover, completion, rename, format,
        # refactor, etc, using semantic whole-project analysis.
        # > :checkhealth lsp
        # https://github.com/neovim/nvim-lspconfig
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              local ts = require("telescope.builtin")

              -- The LspAttach event is fired after an LSP client attaches to a buffer.
              -- https://neovim.io/doc/user/lsp.html
              -- https://microsoft.github.io/language-server-protocol/specifications/specification-current
              vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                  local client = vim.lsp.get_client_by_id(args.data.client_id)
                  local buf = args.buf

                  -- Overwrite treesitter-refactor's basic go-to-definition and
                  -- smart_rename keymaps if supported by the server.
                  if client.supports_method("textDocument/definition") then
                    vim.keymap.set("n", "gd", ts.lsp_definitions, { buffer = args.buf })
                  end
                  if client.supports_method("textDocument/rename") then
                    vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = args.buf })
                  end
                end,
              })

              -- The following keymaps are defined irregardless of the LSP
              -- server's capabilities since we would rather receive an error
              -- that the action is unsupported by the LSP server instead of doing
              -- some other random action.
              vim.keymap.set("n", "grr", ts.lsp_references)
              vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
              vim.keymap.set("n", "gy", vim.lsp.buf.type_definition)
              vim.keymap.set("n", "gI", ts.lsp_implementations)
              vim.keymap.set("n", "<Leader>gq", vim.lsp.buf.format)

              -- TODO: This becomes default in newer neovim?
              vim.keymap.set("n", "gra", vim.lsp.buf.code_action)

              -- CTRL-S is mapped to signature help in insert mode by default.
              -- Add it to normal mode as well.
              vim.keymap.set({"i", "n"}, "<C-s>", vim.lsp.buf.signature_help)

              -- LSP servers and clients communicate what features they support.
              -- By default, neovim does not support everything in the LSP
              -- specification. When we add plugins such as nvim-cmp, neovim now
              -- has more capabilities, so we must add these to the capabilities
              -- that are broadcast to each server.
              -- https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua
              local capabilities = vim.lsp.protocol.make_client_capabilities()
              capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

              local lspconfig = require("lspconfig")

              -- https://github.com/nix-community/nixd
              lspconfig.nixd.setup({
                capabilities = capabilities,
                settings = {
                  nixd = {
                    formatting = {
                      command = {"${pkgs.alejandra}/bin/alejandra"},
                    },
                  },
                },
              })

              -- https://docs.basedpyright.com
              lspconfig.basedpyright.setup({
                capabilities = capabilities,
                settings = {
                  basedpyright = {
                    analysis = {
                      -- https://docs.basedpyright.com/#/configuration?id=diagnostic-settings-defaults
                      typeCheckingMode = "standard",
                    },
                  },
                },
              })
            '';
        }

        # Telescope is a highly extendable fuzzy finder.
        # https://github.com/nvim-telescope/telescope.nvim
        # https://github.com/nvim-telescope/telescope.nvim/wiki/Extensions
        {
          plugin = telescope-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              local actions = require("telescope.actions")
              require("telescope").setup({
                defaults = {
                  mappings = {
                    i = {
                      -- Quit telescope directly from insert mode, instead of
                      -- entering normal mode.
                      -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes
                      ["<Esc>"] = actions.close,

                      -- Use CTRL-{JK} to navigate dropdowns like CTRL-{NP}
                      ["<C-j>"] = actions.move_selection_next,
                      ["<C-k>"] = actions.move_selection_previous,
                      -- Use CTRL-L to confirm selection
                      ["<C-l>"] = actions.select_default,
                    },
                  },
                },
              })

              -- Keymaps mostly inspired by the popular distros.
              -- NOTE: Some mappings are done conditionally on LspAttach.
              -- https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#vim-pickers
              local ts = require("telescope.builtin")
              vim.keymap.set("n", "<Leader>fb", ts.buffers)
              vim.keymap.set("n", "<Leader>fc", ts.commands)
              vim.keymap.set("n", "<Leader>fd", ts.diagnostics)
              vim.keymap.set("n", "<Leader>fF", function() ts.find_files({hidden=true, no_ignore=true}) end)
              vim.keymap.set("n", "<Leader>ff", ts.find_files)
              vim.keymap.set("n", "<Leader>fh", ts.help_tags)
              vim.keymap.set("n", "<Leader>fk", ts.keymaps)
              vim.keymap.set("n", "<Leader>fm", ts.marks)
              vim.keymap.set("n", "<Leader>fo", ts.oldfiles)
              vim.keymap.set("n", "<Leader>fr", ts.registers)
              vim.keymap.set("n", "<Leader>f/", ts.current_buffer_fuzzy_find)
              vim.keymap.set("n", "<Leader>F", ts.resume)
              vim.keymap.set("n", "<Leader>fW", function() ts.live_grep({additional_args={"--hidden", "--no-ignore"}}) end)
              vim.keymap.set("n", "<Leader>fw", ts.live_grep)
            '';
        }
        # It's suggested to install one native sorter for telescope for better
        # performance.
        # https://github.com/nvim-telescope/telescope-fzf-native.nvim
        {
          plugin = telescope-fzf-native-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("telescope").load_extension("fzf")
            '';
        }
        # Replace `vim.ui.select` to Telescope. That means for example that
        # neovim core stuff can fill the telescope picker. Example would be lua
        # `vim.lsp.buf.code_action()`.
        # https://github.com/nvim-telescope/telescope-ui-select.nvim
        {
          plugin = telescope-ui-select-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("telescope").load_extension("ui-select")
            '';
        }

        # Buffer list that lives in the tabline.
        # https://github.com/akinsho/bufferline.nvim
        {
          plugin = bufferline-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("bufferline").setup({})
              -- Use <A-j> and <A-k> to go to previous/next buffer
              vim.keymap.set("n", "<A-j>", vim.cmd.BufferLineCyclePrev);
              vim.keymap.set("n", "<A-k>", vim.cmd.BufferLineCycleNext);
              -- Use <A-[1-9]> to select a buffer. <A-9> selects the rightmost
              -- buffer like tabs in Firefox.
              vim.keymap.set("n", "<A-1>", function() vim.cmd.BufferLineGoToBuffer(1) end);
              vim.keymap.set("n", "<A-2>", function() vim.cmd.BufferLineGoToBuffer(2) end);
              vim.keymap.set("n", "<A-3>", function() vim.cmd.BufferLineGoToBuffer(3) end);
              vim.keymap.set("n", "<A-4>", function() vim.cmd.BufferLineGoToBuffer(4) end);
              vim.keymap.set("n", "<A-5>", function() vim.cmd.BufferLineGoToBuffer(5) end);
              vim.keymap.set("n", "<A-6>", function() vim.cmd.BufferLineGoToBuffer(6) end);
              vim.keymap.set("n", "<A-7>", function() vim.cmd.BufferLineGoToBuffer(7) end);
              vim.keymap.set("n", "<A-8>", function() vim.cmd.BufferLineGoToBuffer(8) end);
              vim.keymap.set("n", "<A-9>", function() vim.cmd.BufferLineGoToBuffer(-1) end);
              -- Use <A-x> to close current buffer
              vim.keymap.set("n", "<A-x>", vim.cmd.bd);
            '';
        }

        # Indentation guides.
        # https://github.com/lukas-reineke/indent-blankline.nvim
        {
          plugin = indent-blankline-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("ibl").setup({
                indent = {
                  -- Thinner indent line
                  char = "▏",
                },
                scope = {
                  -- Don't show start/end of scope horizontal lines
                  show_start = false,
                  show_end = false,
                },
              })
            '';
        }

        # Automatic indentation style detection for Neovim.
        # https://github.com/NMAC427/guess-indent.nvim
        {
          plugin = guess-indent-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("guess-indent").setup({})
            '';
        }

        # A super powerful autopair plugin for Neovim that supports multiple
        # characters; automatically closes brackets etc.
        # https://github.com/windwp/nvim-ts-autotag
        {
          plugin = nvim-autopairs;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("nvim-autopairs").setup({})
            '';
        }

        # Add/change/delete surrounding delimiter pairs with ease; cs, ds, ys.
        # https://github.com/kylechui/nvim-surround
        {
          plugin = nvim-surround;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("nvim-surround").setup({})
            '';
        }

        # Use treesitter to autoclose and autorename html tags.
        # https://github.com/windwp/nvim-ts-autotag
        {
          plugin = nvim-ts-autotag;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("nvim-ts-autotag").setup({})
            '';
        }

        # Git integration for buffers.
        # https://github.com/lewis6991/gitsigns.nvim
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("gitsigns").setup({})
              -- TODO: keybinds
            '';
        }

        # Single tabpage interface for easily cycling through diffs for all
        # modified files for any git rev.
        # https://github.com/sindrets/diffview.nvim
        {
          plugin = diffview-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("diffview").setup({
                enhanced_diff_hl = true,
              })
              vim.keymap.set("n", "<Leader>gd", vim.cmd.DiffviewOpen)
            '';
        }

        # TODO
        ########################

        # A blazing fast and easy to configure statusline written in Lua.
        # https://github.com/nvim-lualine/lualine.nvim
        {
          plugin = lualine-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("lualine").setup({})
            '';
        }

        # TODO!
        vim-fugitive

        # mini-nvim

        # TODO: popup file-tree/viewer??

        # nvim-colorizer-lua # show colours in colours
        # vim-matchup # better %
        # nvim-dap # debug adapter protocol
        # nvim-dap-virtual-text # show variable values in-line
        # salt-vim # salt syntax-highlighting
        # https://github.com/JoosepAlviste/nvim-ts-context-commentstring
      ];
      extraPackages = [
        nixpkgs-unstable.legacyPackages.${pkgs.system}.basedpyright
        pkgs.nixd
      ];
      extraLuaPackages = ps: [];
      extraPython3Packages = ps: [];
      # withNodeJs = true;
    };

    # https://wiki.nixos.org/wiki/Vim#Vim_Spell_Files
    home.file.".config/nvim/spell/da.utf-8.spl".source = builtins.fetchurl {
      url = "http://ftp.vim.org/vim/runtime/spell/da.utf-8.spl";
      sha256 = "0cl9q1ln7y4ihbpgawl3rc86zw8xynq9hg4hl8913dbmpcl2nslj";
    };
    home.file.".config/nvim/spell/da.utf-8.sug".source = builtins.fetchurl {
      url = "http://ftp.vim.org/vim/runtime/spell/da.utf-8.sug";
      sha256 = "1pdnp0hq3yll65z6rlmq0l6axvn5450jw5y081vyb4x5850czdxm";
    };
  };
}
