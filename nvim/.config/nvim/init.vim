""""""""""""""""""""""""""""""""""""""
"            PLUGINS                 "
""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.local/share/nvim/plugged')

Plug 'joshdick/onedark.vim'     " colorscheme
Plug 'itchyny/lightline.vim'    " status bar
Plug 'szw/vim-maximizer'        " tmux C-z
Plug 'Valloric/YouCompleteMe'   " autocompletion
Plug 'SpaceVim/cscope.vim'      " cscope set of configs
Plug 'Yggdroot/indentLine'      " draw indent guides (not so good)

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

" indent using 2 spaces
set expandtab      " convert TAB into spaces
set smarttab       " TAB respects 'tabstop', 'shiftwidth', and 'softtabstop'
set tabstop=2      " number of visual spaces per TAB
set softtabstop=2  " number of spaces in TAB when editing
set shiftwidth=2   " number of spaces to use for indent and unindent
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
set foldlevel=0        " starting fold depth

" open splits towards the bottom right corner
set splitbelow
set splitright

" allow to minimize unsaved buffers
set hidden

" restore cursor shape to underline when leaving nvim
au VimLeave * set guicursor=a:hor100

" set vertical split and fold characters
set fillchars=vert:\ ,fold:-

" show invisible characters
set list
set listchars=tab:→\ ,eol:↩,trail:⋅,extends:❯,precedes:❮
set showbreak=↪

" indent guides plugin
let g:indentLine_char='┆'
let g:indentLine_first_char='┆'
let g:indentLine_showFirstIndentLevel=1


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

" scroll text 3x faster with C-j and C-k
noremap <C-j> 3<C-e>
noremap <C-k> 3<C-y>

" scroll window with C-p and C-n
noremap <C-p> <C-u>
noremap <C-n> <C-d>

" set exit terminal mode to esc key
" tnoremap <Esc> <C-\><C-n>

" ctags
" open the definition in a vertical split
map <C-w><A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" cscope
nnoremap <leader>fa :call CscopeFindInteractive(expand('<cword>'))<CR>
nnoremap <leader>l :call ToggleLocationList()<CR>
" s: Find this C symbol
nnoremap  <leader>fs :call CscopeFind('s', expand('<cword>'))<CR>
" g: Find this definition
nnoremap  <leader>fg :call CscopeFind('g', expand('<cword>'))<CR>
" d: Find functions called by this function
nnoremap  <leader>fd :call CscopeFind('d', expand('<cword>'))<CR>
" c: Find functions calling this function
nnoremap  <leader>fc :call CscopeFind('c', expand('<cword>'))<CR>
" t: Find this text string
nnoremap  <leader>ft :call CscopeFind('t', expand('<cword>'))<CR>
" e: Find this egrep pattern
nnoremap  <leader>fe :call CscopeFind('e', expand('<cword>'))<CR>
" f: Find this file
nnoremap  <leader>ff :call CscopeFind('f', expand('<cword>'))<CR>
" i: Find files #including this file
nnoremap  <leader>fi :call CscopeFind('i', expand('<cword>'))<CR>

" closing chars
ino < <><left>
ino " ""<left>
ino ' ''<left>
ino ( ()<left>
ino (; ();<left><left>
ino [ []<left>
ino { {}<left>
ino {<CR> { <ESC>Do<C-r>"<ESC>0xo}<ESC>kA
ino {;<CR> {<CR>};<ESC>O

" del in insert mode
inoremap <C-d> <Del>


""""""""""""""""""""""""""""""""""""""
"           COLORSCHEME              "
""""""""""""""""""""""""""""""""""""""

colorscheme onedark
highlight Normal ctermbg=none
highlight Comment ctermfg=241 cterm=italic,bold
highlight LineNr ctermfg=248 ctermbg=239
highlight CursorLineNr ctermfg=255 ctermbg=236 cterm=bold
highlight VertSplit ctermbg=none
highlight SignColumn ctermbg=236
highlight Folded ctermbg=236
highlight Error ctermbg=203 ctermfg=240 cterm=bold
highlight MatchParen ctermbg=3 cterm=bold
highlight StorageClass ctermfg=9
highlight Function ctermfg=76
highlight Type ctermfg=45
highlight Identifier ctermfg=229
highlight String ctermfg=227
highlight Brackets ctermfg=172
highlight Ponctuation ctermfg=206
highlight Address ctermfg=230
highlight Number ctermfg=152
highlight cFuncCall ctermfg=2
highlight Symbols ctermfg=9
highlight Equals ctermfg=9

