""""""""""""""""""""""""""""""""""""""
"               GENERAL              "
""""""""""""""""""""""""""""""""""""""

" show hybrid line numbers 
set number relativenumber

" configure line wrapping
set wrap

" highlith current line
set cursorline

" highlith column 80
set colorcolumn=80

" indent using 4 spaces
set expandtab      " convert TAB into spaces
set smarttab       " TAB respects 'tabstop', 'shiftwidth', and 'softtabstop'
set tabstop=4      " number of visual spaces per TAB
set softtabstop=4  " number of spaces in TAB when editing
set shiftwidth=4   " number of spaces to use for indent and unindent
set shiftround     " round indent to a multiple of 'shiftwidth'

" file type detection
filetype indent on

" enable visual autocomplete for command menu
set wildmenu

" enhance searches
set incsearch    " search as characters are typed
set hlsearch     " highlight matches
nnoremap <esc> : noh<return><esc>   " unhighligh last match

" folding code
set foldenable
set foldmethod=indent  " fold based on indent level

" move vertically by visual line
nnoremap j gj
nnoremap k gk

" maps gV to highlight last inserted text
nnoremap gV `[v`]


""""""""""""""""""""""""""""""""""""""
"            PLUGINS                 "
""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.local/share/nvim/plugged')

Plug 'chriskempson/base16-vim'  " colorscheme
Plug 'joshdick/onedark.vim'     " colorscheme
Plug 'itchyny/lightline.vim'    " status line

call plug#end()

