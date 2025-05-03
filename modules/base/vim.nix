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

          -- Show line numbers
          vim.opt.number = true

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

          -- Send CursorHold autocommand event after 100ms (instead of 4000ms
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
          vim.opt.diffopt:append({"algorithm:histogram", "indent-heuristic"})
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

          -- Use ALT-{PY} to paste and yank from the system clipboard
          vim.keymap.set({"n", "v"}, "<M-p>", "\"+p")
          vim.keymap.set("n", "<M-P>", "\"+P")
          vim.keymap.set({"n", "v"}, "<M-y>", "\"+y")
          vim.keymap.set("n", "<M-Y>", "\"+y$")
          vim.keymap.set("n", "<M-y><M-y>", "\"+yy")

          -- Use CTRL-{JK} to navigate dropdowns, like CTRL-{NP}, in insert and
          -- command mode.
          vim.keymap.set({"c", "i"}, "<C-j>",  "<C-n>")
          vim.keymap.set({"c", "i"}, "<C-k>",  "<C-p>")

          -- Use CTRL-{HJKL} to navigate windows
          vim.keymap.set("n", "<C-h>",  "<C-w><C-h>")
          vim.keymap.set("n", "<C-j>",  "<C-w><C-j>")
          vim.keymap.set("n", "<C-k>",  "<C-w><C-k>")
          vim.keymap.set("n", "<C-l>",  "<C-w><C-l>")

          -- Use ALT-{HL} to navigate tabs
          vim.keymap.set("n", "<A-h>", "gT");
          vim.keymap.set("n", "<A-l>", "gt");

          -- Use <Escape> to clear search highlight. This is normally bound to
          -- CTRL-L, but we use that to navigate windows instead.
          vim.keymap.set("n", "<Esc>", vim.cmd.noh)

          -- Restore cursor position when opening a file
          -- https://github.com/neovim/neovim/issues/16339#issuecomment-1457394370
          vim.api.nvim_create_autocmd("BufRead", {
            callback = function(opts)
              vim.api.nvim_create_autocmd("BufWinEnter", {
                once = true,
                buffer = opts.buf,
                callback = function()
                  local ft = vim.bo[opts.buf].filetype
                  local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
                  if
                    not (ft:match("commit") and ft:match("rebase"))
                    and last_known_line > 1
                    and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
                  then
                    vim.api.nvim_feedkeys([[g`"]], "nx", false)
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
            # lua
            ''
              require("kanagawa").setup({
                theme = "wave",
                commentStyle = { italic = false },
                keywordStyle = { italic = false },
                statementStyle = { bold = false },
                dimInactive = true,
                colors = {
                  theme = {
                    wave = {
                      syn = {
                        -- Make control flow keywords more pronounced.
                        -- statement = colors.theme.syn.special2,
                        keyword = "#E46876"  -- waveRed; same as syn.special2
                      },
                    },
                    all = {
                      ui = {
                        -- Don't use a special background for the gutter
                        bg_gutter = "none",
                      },
                    },
                  },
                },
                -- https://github.com/rebelot/kanagawa.nvim/blob/master/lua/kanagawa/themes.lua
                -- https://github.com/rebelot/kanagawa.nvim/blob/master/lua/kanagawa/highlights/syntax.lua
                -- See `:h highlight-groups` and `:h group-name`.
                overrides = function(colors)
                  local theme = colors.theme
                  return {
                    -- Show booleans like other special symbols such as 'None'
                    -- in Python.
                    Boolean = { fg = theme.syn.special1, bold = false },
                    -- Transparent Floating Windows
                    NormalFloat = { bg = "none" },
                    FloatBorder = { bg = "none" },
                    FloatTitle = { bg = "none" },
                    -- Less pronounced cursorline
                    CursorLine = { bg = theme.ui.bg_p1 },
                    -- More pronounced window borders
                    WinSeparator = { fg = theme.ui.nontext },
                    -- Less pronounced indent lines
                    IblIndent = { fg = theme.ui.bg_p2 },
                    IblScope = { fg = theme.ui.whitespace },
                    -- Don't overwrite syntax-highlighting on deleted lines
                    DiffDelete = { fg = "none" },
                  }
                end,
              })
              vim.cmd.colorscheme("kanagawa")
            '';
        }

        # Adds file type icons to Vim plugins.
        # https://github.com/nvim-tree/nvim-web-devicons
        {plugin = nvim-web-devicons;}

        # Rearrange window layout using sway-like <Ctrl-Shift-{hjkl}> bindings.
        # https://github.com/sindrets/winshift.nvim
        {
          plugin = winshift-nvim;
          type = "lua";
          config =
            # lua
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
            # lua
            ''
              require("nvim-treesitter.configs").setup({
                -- Consistent syntax highlighting
                highlight = {
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
            # lua
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
            # lua
            ''
              require("treesitter-context").setup({
                -- Show one line of context at the top of the screen
                max_lines = 2,
              })
            '';
        }

        # Performant, batteries-included completion plugin for Neovim.
        # https://github.com/Saghen/blink.cmp
        # https://cmp.saghen.dev
        {
          plugin = blink-cmp;
          type = "lua";
          config =
            # lua
            ''
              require("blink.cmp").setup({
                keymap = {
                  -- Add telescope-like mappings in addition to the default
                  -- https://cmp.saghen.dev/configuration/keymap.html#super-tab
                  preset = "super-tab",
                  ["<C-j>"] = { "select_next", "fallback_to_mappings" },
                  ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
                  ["<C-l>"] = {
                    function(cmp)
                      if cmp.snippet_active() then return cmp.accept()
                      else return cmp.select_and_accept() end
                    end,
                    "snippet_forward",
                    "fallback"
                  },
                  ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                  ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                },
                -- Automatically show documentation next to completions menu
                completion = {
                  documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 50,
                  },
                  -- Displays a preview of the selected item on the current line
                  ghost_text = {
                    enabled = true,
                  },
                },
                -- Enable experimental signature help support
                signature = {
                  enabled = true,
                  window = {
                    show_documentation = false,
                  },
                },
                fuzzy = {
                  -- Disable automatic download of prebuilt binaries from
                  -- GitHub. It is already included in nixpkgs blink-cmp.
                  prebuilt_binaries = {
                    download = false,
                  },
                },
              })
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
            # lua
            ''
              local ts = require("telescope.builtin")

              -- The LspAttach event is fired after an LSP client attaches to a buffer.
              -- https://neovim.io/doc/user/lsp.html
              -- https://microsoft.github.io/language-server-protocol/specifications/specification-current
              vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                  local client = vim.lsp.get_client_by_id(args.data.client_id)
                  local buf = args.buf

                  -- Overwrite treesitter-refactor's basic go-to-definition
                  -- keymap if supported by the server.
                  if client.supports_method("textDocument/definition") then
                    vim.keymap.set("n", "gd", ts.lsp_definitions, { buffer = args.buf })
                  end
                end,
              })

              -- The following keymaps are defined irregardless of the LSP
              -- server's capabilities since we would rather receive an error
              -- that the action is unsupported by the LSP server instead of doing
              -- some other random action.
              vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
              vim.keymap.set("n", "gy", vim.lsp.buf.type_definition)
              vim.keymap.set("n", "gI", ts.lsp_implementations)

              -- LSP servers and clients communicate what features they support.
              -- By default, neovim does not support everything in the LSP
              -- specification. When we add plugins such as blink, neovim now
              -- has more capabilities, so we must add these to the capabilities
              -- that are broadcast to each server.
              -- https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua
              local capabilities = vim.lsp.protocol.make_client_capabilities()
              capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))

              local lspconfig = require("lspconfig")

              -- https://github.com/golang/tools/tree/master/gopls
              lspconfig.gopls.setup({
                capabilities = capabilities,
              })

              -- https://github.com/nix-community/nixd
              lspconfig.nixd.setup({
                capabilities = capabilities,
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

              -- https://github.com/rust-lang/rust-analyzer
              lspconfig.rust_analyzer.setup({
                capabilities = capabilities,
                settings = {
                  ["rust-analyzer"] = {
                    diagnostics = {
                      enable = true;
                    },
                  },
                },
              })

              -- https://github.com/redhat-developer/yaml-language-server
              lspconfig.yamlls.setup({
                capabilities = capabilities,
                settings = {
                  yaml = {
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
            # lua
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
                extensions = {
                  -- Use vertical layout to allow enough width for
                  -- side-by-side diffs.
                  undo = {
                    layout_strategy = "vertical",
                    layout_config = {
                      preview_height = 0.8,
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
              vim.keymap.set("n", "<Leader>fq", ts.quickfix)
              vim.keymap.set("n", "<Leader>fr", ts.registers)
              vim.keymap.set("n", "<Leader>fs", ts.lsp_dynamic_workspace_symbols)
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
            # lua
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
            # lua
            ''
              require("telescope").load_extension("ui-select")
            '';
        }
        # Visualize your undo tree and fuzzy-search changes in it. For those
        # days where committing early and often doesn't work out.
        # https://github.com/debugloop/telescope-undo.nvim
        {
          plugin = telescope-undo-nvim;
          type = "lua";
          config =
            # lua
            ''
              local telescope = require("telescope")
              telescope.load_extension("undo")
              vim.keymap.set("n", "<Leader>fu", telescope.extensions.undo.undo)
            '';
        }

        # Buffer list that lives in the tabline.
        # https://github.com/akinsho/bufferline.nvim
        {
          plugin = bufferline-nvim;
          type = "lua";
          config =
            # lua
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

        # Lightweight yet powerful formatter plugin for Neovim.
        # https://github.com/stevearc/conform.nvim
        {
          plugin = conform-nvim;
          type = "lua";
          config =
            # lua
            ''
              -- TODO: injected language formatting (treesitter code blocks)
              local conform = require("conform")
              conform.setup({
                formatters_by_ft = {
                  -- Use conform built-ins on all ("*") filetypes
                  ["*"] = {"trim_newlines", "trim_whitespace"},
                  css = {"prettier"},
                  graphql = {"prettier"},
                  html = {"prettier"},
                  javascript = {"prettier"},
                  json = {"prettier"},
                  markdown = {"prettier"},
                  nix = {"alejandra"},
                  -- Ruff follows the project's pyproject.toml/ruff.toml
                  python = {"ruff_fix", "ruff_organize_imports", "ruff_format"},
                  rust = {"rustfmt"},
                  terraform = {"tofu_fmt"},
                  toml = {"taplo"},
                  typescript = {"prettier"},
                  yaml = {"prettier"},
                },
              })
              vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
              vim.keymap.set("n", "<Leader>gq", conform.format)
            '';
        }

        # Indentation guides.
        # https://github.com/lukas-reineke/indent-blankline.nvim
        {
          plugin = indent-blankline-nvim;
          type = "lua";
          config =
            # lua
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
            # lua
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
            # lua
            ''
              require("nvim-autopairs").setup({})
            '';
        }

        # Neovim's answer to the mouse 🦘
        # https://github.com/ggandor/leap.nvim/
        {
          plugin = leap-nvim;
          type = "lua";
          config =
            # lua
            ''
              require("leap").create_default_mappings()
              -- Suggested additional tweak: Use the traversal keys to repeat
              -- the previous motion without explicitly invoking Leap.
              require("leap.user").set_repeat_keys("<enter>", "<backspace>")
            '';
        }

        # Add/change/delete surrounding delimiter pairs with ease; cs, ds, ys.
        # https://github.com/kylechui/nvim-surround
        {
          plugin = nvim-surround;
          type = "lua";
          config =
            # lua
            ''
              require("nvim-surround").setup({
                keymaps = {
                  -- nvim-surround uses upper-case S and gS for visual-mode
                  -- surround by default, presumably to avoid clashing with
                  -- s(substitute). We use s for leap -- which doesn't make sense
                  -- from visual mode anyway -- so we might as well use lower-case
                  -- s for visual-mode surround.
                  visual = "s",
                  visual_line = "gs",
                },
              })
            '';
        }

        # Use treesitter to autoclose and autorename html tags.
        # https://github.com/windwp/nvim-ts-autotag
        {
          plugin = nvim-ts-autotag;
          type = "lua";
          config =
            # lua
            ''
              require("nvim-ts-autotag").setup({})
            '';
        }

        # Better quickfix window in Neovim.
        # https://github.com/kevinhwang91/nvim-bqf
        {
          plugin = nvim-bqf;
          type = "lua";
        }

        # An interactive and powerful Git interface for Neovim, inspired by
        # Magit.
        # https://github.com/NeogitOrg/neogit
        {
          plugin = neogit;
          type = "lua";
          config =
            # lua
            ''
              require("neogit").setup({
                graph_style = "unicode",
              })
              vim.keymap.set("n", "<Leader>gg", vim.cmd.Neogit)
            '';
        }

        # Git integration for buffers.
        # https://github.com/lewis6991/gitsigns.nvim
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config =
            # lua
            ''
              require("gitsigns").setup({
                -- https://github.com/lewis6991/gitsigns.nvim?tab=readme-ov-file#keymaps
                on_attach = function(bufnr)
                  local gitsigns = require("gitsigns")

                  local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                  end

                  -- Navigation
                  map("n", "]c", function()
                    if vim.wo.diff then
                      vim.cmd.normal({"]c", bang = true})
                    else
                      gitsigns.nav_hunk("next")
                    end
                  end)

                  map("n", "[c", function()
                    if vim.wo.diff then
                      vim.cmd.normal({"[c", bang = true})
                    else
                      gitsigns.nav_hunk("prev")
                    end
                  end)

                  -- Actions
                  map("n", "<leader>hs", gitsigns.stage_hunk)
                  map("n", "<leader>hr", gitsigns.reset_hunk)
                  map("v", "<leader>hs", function() gitsigns.stage_hunk {vim.fn.line("."), vim.fn.line("v")} end)
                  map("v", "<leader>hr", function() gitsigns.reset_hunk {vim.fn.line("."), vim.fn.line("v")} end)
                  map("n", "<leader>hS", gitsigns.stage_buffer)
                  map("n", "<leader>hu", gitsigns.undo_stage_hunk)
                  map("n", "<leader>hR", gitsigns.reset_buffer)
                  map("n", "<leader>hp", gitsigns.preview_hunk)
                  map("n", "<leader>hb", function() gitsigns.blame_line{full=true} end)
                  map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
                  map("n", "<leader>hd", gitsigns.diffthis)
                  map("n", "<leader>hD", function() gitsigns.diffthis("~") end)
                  map("n", "<leader>td", gitsigns.toggle_deleted)

                  -- Text object
                  map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>")
                end
              })
            '';
        }

        # Single tabpage interface for easily cycling through diffs for all
        # modified files for any git rev.
        # https://github.com/sindrets/diffview.nvim
        {
          plugin = diffview-nvim;
          type = "lua";
          config =
            # lua
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
            # lua
            ''
              require("lualine").setup({})
            '';
        }

        # A File Explorer For Neovim Written In Lua.
        # https://github.com/nvim-tree/nvim-tree.lua
        {
          plugin = nvim-tree-lua;
          type = "lua";
          config =
            # lua
            ''
              require("nvim-tree").setup({
                filters = {
                  custom = {
                    "^\\.git",
                  },
                },
              })
              vim.keymap.set("n", "<Leader>e", vim.cmd.NvimTreeToggle)
            '';
        }
      ];
      extraPackages = [
        nixpkgs-unstable.legacyPackages.${pkgs.system}.basedpyright # lsp
        nixpkgs-unstable.legacyPackages.${pkgs.system}.ruff # lsp/conform
        pkgs.alejandra # conform
        pkgs.gopls # lsp
        pkgs.nixd # lsp
        pkgs.nodePackages.prettier # conform
        pkgs.opentofu # conform
        pkgs.rust-analyzer # lsp
        pkgs.rustfmt # conform
        pkgs.taplo # conform
        pkgs.yaml-language-server # lsp
      ];
      extraLuaPackages = ps: [];
      extraPython3Packages = ps: [];
      # withNodeJs = true;
    };

    # https://wiki.nixos.org/wiki/Vim#Vim_Spell_Files
    # Default neovim URL: `:let g:spellfile_URL`.
    home.file.".config/nvim/spell/da.utf-8.spl".source = builtins.fetchurl {
      url = "https://ftp.nluug.nl/pub/vim/runtime/spell/da.utf-8.spl";
      sha256 = "0cl9q1ln7y4ihbpgawl3rc86zw8xynq9hg4hl8913dbmpcl2nslj";
    };
    home.file.".config/nvim/spell/da.utf-8.sug".source = builtins.fetchurl {
      url = "https://ftp.nluug.nl/pub/vim/runtime/spell/da.utf-8.sug";
      sha256 = "1pdnp0hq3yll65z6rlmq0l6axvn5450jw5y081vyb4x5850czdxm";
    };
  };
}
