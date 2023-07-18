syntax on                   " syntax highlighting

set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching 
set ignorecase              " case insensitive 
set mouse=v                 " middle-click paste
set hlsearch                " highlight search 
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set noswapfile              " disable creating swap file

set tw=0                    " disable auto line break

" KM disabled these for now - they're annoying or don't work right
"set expandtab               " converts tabs to white space
"set spell                   " enable spell check
"set backupdir=~/.cache/vim  " Directory to store backup files.
"set cc=88                   " set an 88 column border for good coding style

filetype plugin indent on   " allow auto-indenting depending on file type
filetype plugin on          " run autocommands based on filetype

" Consider jk or kj (when entered in succession) to be ESC
inoremap jk <ESC>
inoremap kj <ESC>

" Point to neovim virtualenv.
" let g:python3_host_prog = '~/.config/nvim/venv/bin/python'
" let g:vim_isort_python_version = 'python3'
" let g:black_virtualenv = '~/.config/nvim/venv'

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Begin plugin block
call plug#begin('~/.config/nvim/plugged')

Plug 'editorconfig/editorconfig-vim'
" Plug 'elmcast/elm-vim'
" Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
" Plug 'psf/black'
" Plug 'fisadev/vim-isort'
" Plug 'ycm-core/YouCompleteMe'
Plug 'hashivim/vim-terraform'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeFind' }
" Plug 'junegunn/fzf'

call plug#end()
" End plugin block
""""""""""""""""""""""""""""""""""""""""""""""""""""""

nmap <leader>n :NERDTreeFocus<CR>
nmap <C-n> :NERDTree<CR>
nmap <C-t> :NERDTreeToggle<CR>
nmap <C-f> :NERDTreeFind<CR>
