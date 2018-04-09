""""""""""""""""""""""""""""""""""""""
"            PLUGINS                 "
""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.local/share/nvim/plugged')

Plug 'chriskempson/base16-vim'  " colorscheme
Plug 'joshdick/onedark.vim'     " colorscheme
Plug 'itchyny/lightline.vim'    " status line
Plug 'szw/vim-maximizer'        " tmux C-z

call plug#end()


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

" folding code
set foldenable
set foldmethod=indent  " fold based on indent level

" open splits towards the bottom right corner
set splitbelow
set splitright


""""""""""""""""""""""""""""""""""""""
"           KEYBINDINGS              "
""""""""""""""""""""""""""""""""""""""

" move vertically by visual line
nnoremap j gj
nnoremap k gk

" maps gV to highlight last inserted text
nnoremap gV `[v`]

" maps vim-maximizer plugin shortcut to match tmux
nnoremap <silent><C-w>z :MaximizerToggle<CR>
vnoremap <silent><C-w>z :MaximizerToggle<CR>gv
" inoremap <silent><C-w>z <C-o>:MaximizerToggle<CR>

" unhighlight last match
nnoremap <esc> :noh<return><esc>   


""""""""""""""""""""""""""""""""""""""
"           COLORSCHEME              "
""""""""""""""""""""""""""""""""""""""
colorscheme onedark
highlight Normal ctermbg=none
highlight Comment ctermfg=blue cterm=bold
highlight LineNr ctermfg=white
highlight CursorLineNr ctermfg=gray cterm=bold

