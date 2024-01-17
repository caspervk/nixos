" Colour scheme
colorscheme kanagawa
set termguicolors

" Show relative line numbers and highlight the current one
set number
set relativenumber
set cursorline
set cursorlineopt=number

" Keep some context above and below the cursor
set scrolloff=3
set sidescrolloff=3

" Tabs are spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" Better search
set ignorecase
set smartcase

" Jump to new splits automatically
set splitbelow
set splitright

" Visualise trailing whitespace
set list
set listchars=tab:▸\ ,trail:·,nbsp:␣

" Spelling
set spell
set spelllang=en_us,en_gb,da_dk

" Use space as leader key
nnoremap <Space> <Nop>
let mapleader = "\<Space>"

" Keep visual selection after indenting
vnoremap > >gv
vnoremap < <gv

