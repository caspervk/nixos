-- https://github.com/rebelot/kanagawa.nvim
require('kanagawa').setup({
    undercurl = true,
    commentStyle = {italic = false},
    keywordStyle = {italic = false},
    theme = "dragon",
    background = {
        dark = "dragon",
        light = "lotus"
    }
})

-- https://github.com/lukas-reineke/indent-blankline.nvim
require('indent_blankline').setup({
    show_current_context = true,
})

-- https://github.com/numToStr/Comment.nvim
require("Comment").setup()

-- https://github.com/ggandor/leap.nvim/
require("leap").add_default_mappings()

-- https://github.com/NvChad/nvim-colorizer.lua
require('colorizer').setup({user_default_options = {names = false}})

-- https://github.com/nvim-treesitter/nvim-treesitter
require('nvim-treesitter.configs').setup({
    highlight = {
        enable = true
    },
    refactor = {
        highlight_definitions = {
            enable = true,
            clear_on_cursor_move = true,
        },
        smart_rename = {
            enable = true,
            keymaps = {
                smart_rename = "grr"
            }
        },
        navigation = {
            enable = true,
            keymaps = {
              goto_definition = "gnd",
              list_definitions = "gnD",
              list_definitions_toc = "gO",
              goto_next_usage = "<a-*>",
              goto_previous_usage = "<a-#>",
            }
        },
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            node_decremental = "<C-M-space>",
            scope_incremental = false,
        }
    },
    matchup = {
        enable = true,
    },
    textobjects = {
        swap = {
            enable = true,
            swap_next = {["<leader>a"] = "@parameter.inner"},
            swap_previous = {["<leader>A"] = "@parameter.inner"}
        }
    },
})

-- https://github.com/nvim-treesitter/nvim-treesitter-context
require('treesitter-context').setup({
    mode = "topline",
})


-- https://github.com/nvim-tree/nvim-tree.lua
require("nvim-tree").setup({
    -- Automatically show tree from the project root
    -- https://github.com/ahmedkhalf/project.nvim
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true,
    },
})


-- https://github.com/ahmedkhalf/project.nvim
require("project_nvim").setup()


-- TODO
require("nvim-dap-virtual-text").setup()

