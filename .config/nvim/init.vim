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
"set cc=88                   " set an 88 column border for good coding style
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set noswapfile              " disable creating swap file

" KM disabled these for now - they're annoying or don't work right
"set expandtab               " converts tabs to white space
"set spell                   " enable spell check
"set backupdir=~/.cache/vim  " Directory to store backup files.

filetype plugin indent on   " allow auto-indenting depending on file type
filetype plugin on          " run autocommands based on filetype

" Consider jk or kj (when entered in succession) to be ESC
inoremap jk <ESC>
inoremap kj <ESC>
