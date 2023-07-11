"            PLUGINS {{{1
""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.local/share/nvim/plugged')

Plug 'github/copilot.vim'                " github suggestions
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
Plug 'ms-jpq/coq.thirdparty', {'branch': '3p'}
"Plug 'deoplete-plugins/deoplete-clang'   " deoplete provider for C/C++
"Plug 'Shougo/deoplete.nvim'              " autocompletion framework
Plug 'junegunn/fzf'                      " fzf integration
Plug 'junegunn/fzf.vim'                  " fzf integration
Plug 'junegunn/goyo.vim'                 " distraction free mode
Plug 'sainnhe/gruvbox-material'          " colorscheme
"Plug 'skywind3000/gutentags_plus'        " cscope useful shortcuts
Plug 'Yggdroot/indentLine'               " draw indent guides (not so good)
"Plug 'jbyuki/instant.nvim'               " pair programming
Plug 'mengelbrecht/lightline-bufferline' " lightline top bar plugin
Plug 'itchyny/lightline.vim'             " status bar
Plug 'junegunn/limelight.vim'            " text color dimmer (used with goyo)
"Plug 'iamcco/markdown-preview.nvim'      " web browser .md preview
"Plug 'neomake/neomake'                   " code linting
"Plug 'EdenEast/nightfox.nvim'            " colorscheme
Plug 'neovim/nvim-lspconfig'
"Plug 'joshdick/onedark.vim'              " colorscheme
"Plug 'SirVer/ultisnips'                  " snippets framework
"Plug 'dracula/vim', { 'as': 'dracula' }  " colorscheme
Plug 'ryanoasis/vim-devicons'            " file type icons
"Plug 'ludovicchabant/vim-gutentags'      " ctags auto generator
Plug 'szw/vim-maximizer'                 " tmux C-z
Plug 'justinmk/vim-sneak'                " quick cursor jump around
"Plug 'honza/vim-snippets'                " ultisnips provider
Plug 'mg979/vim-visual-multi'            " sublime like multi cursors
"Plug 'amix/vim-zenroom2'                 " .md colorscheme when goyo is on
Plug 'lervag/vimtex'                     " LaTeX integration
Plug 'vimwiki/vimwiki'
"Plug 'Valloric/YouCompleteMe'            " autocompletion

call plug#end()
""""""""""""""""""""""""""""""""""""""
"           PLUGINS CONFIG {{{1
""""""""""""""""""""""""""""""""""""""
">----| copilot {{{2
" enable copilot only for certain filetypes
let g:copilot_filetypes = {
  \ '*': v:false,
  \ 'python': v:true,
  \ 'c': v:true,
  \ 'cpp': v:true,
  \ 'go': v:true,
  \ 'vim': v:true,
  \ }

">----| coq_nvim {{{2
let g:coq_settings = {
  \ 'clients.tmux.enabled': v:false,
  \ 'auto_start': 'shut-up',
  \ }

">----| deoplete {{{2
" use deoplete
let g:deoplete#enable_at_startup = 1

">----| deoplete-clang {{{2
let g:deoplete#sources#clang#libclang_path = '/data/data/com.termux/files/usr/lib/libclang.so'
let g:deoplete#sources#clang#clang_header = '/data/data/com.termux/files/usr/lib/clang'

">----| fzf {{{2
" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'
let g:fzf_buffers_jump = 1
let g:fzf_tags_command = 'ctags -R'
" Border color
let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,'yoffset':0.5,'xoffset': 0.5, 'highlight': 'float', 'border': 'sharp' } }
let g:fzf_preview_window = 'down:60%'

let $FZF_DEFAULT_OPTS = '--cycle --preview-window=down:60%:wrap:hidden --preview="preview.sh {}" --bind=ctrl-space:toggle-preview --layout=reverse --inline-info'
let $FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/**'"
"-g '!{node_modules,.git}'

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

"Get Files
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--preview-window=down:60%:wrap']}, <bang>0)


" Get text in files with Rg
" command! -bang -nargs=* Rg
"   \ call fzf#vim#grep(
"   \   "rg --column --line-number --no-heading --color=always --smart-case --glob '!.git/**' ".shellescape(<q-args>), 1,

" Make Ripgrep ONLY search file contents and not filenames
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --hidden --smart-case --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
  \           : fzf#vim#with_preview({'options': '--delimiter : --nth 4.. -e'}, 'down:50%', '?'),
  \   <bang>0)

" Ripgrep advanced
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

" Git grep
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

">----| indentline {{{2
let g:indentLine_char='┆'
let g:indentLine_first_char='┆'
let g:indentLine_showFirstIndentLevel=1

">----| instant {{{2
let g:instant_username='fred'

">----| lightline-bufferline {{{2
let g:lightline#bufferline#show_number=1
let g:lightline#bufferline#clickable=1
let g:lightline#bufferline#enable_devicons=1

">----| lightline {{{2
let g:lightline = {
  \   'active': {
  \     'left': [['mode', 'paste'],
  \              ['readonly', 'filename', 'modified'],
  \              ['windowMaximized']]
  \   },
  \   'inactive': {
  \     'left': [[], ['filename'], ['windowNumber']]
  \   },
  \   'tabline': {
  \     'left': [['tabStatus'], ['buffers']],
  \     'right': [['close']]
  \   },
  \   'component_expand': {
  \     'buffers': 'lightline#bufferline#buffers',
  \   },
  \   'component_type': {
  \     'buffers': 'tabsel'
  \   },
  \   'component_function': {
  \     'windowNumber': 'winnr',
  \     'windowMaximized': 'IsMaximized',
  \     'tabStatus': 'TabStatus',
  \     'modified': 'LightlineModified',
  \     'readonly': 'LightlineReadonly',
  \   },
  \   'component_raw': {
  \     'buffers': 1
  \   },
  \   'separator': {
  \     'left': "", 'right': ""
  \   },
  \   'subseparator': {
  \     'left': "", 'right': ""
  \   },
  \ }

function! LightlineReadonly()
  return &readonly ? '' : ''
endfunction

function! LightlineModified()
  return &modified ? '' : ''
endfunction

function! IsMaximized()
  if exists('t:maximizer_sizes') && t:maximizer_sizes.after == winrestcmd()
    return ''
  else
    return ''
  endif
endfunction

function! TabStatus()
  return tabpagenr() . '/' . tabpagenr("$")
endfunction

">----| limelight {{{2
autocmd! User GoyoEnter Limelight 0.8
autocmd! User GoyoLeave Limelight!

">----| neomake {{{2
"" on changes in normal mode and when writing
"" to a buffer, after 500ms of delay
"call neomake#configure#automake('nw', 500)
"" open quickfix/location list window when error is detected
"let g:neomake_open_list = 2
"" use gcc for C linting
"let g:neomake_c_enabled_makers = ['gcc']
"" disable linting on TeX files
"let g:neomake_tex_enabled_makers = []
"let g:neomake_error_sign = {
"    \ 'text': '>>',
"    \ 'texthl': 'ErrorMsg',
"    \ }
"let g:neomake_warning_sign = {
"    \   'text': '‼',
"    \   'texthl': 'WarningMsg',
"    \ }

">----| nvim-lspconfig {{{2
luafile ~/.config/nvim/lsp.lua

">----| tag {{{2
let g:gutentags_enabled=0

">----| ultilsnips {{{2
let g:UltiSnipsExpandTrigger="<CR>"
let g:UltiSnipsJumpForwardTrigger="<Tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"

">----| vimtex {{{2
" configure it to use Okular as the PDF viewer
" let g:vimtex_view_general_viewer = 'okular'
" let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
" let g:vimtex_view_general_options_latexmk = '--unique'
" configure it to use deoplete
"call deoplete#custom#var('omni', 'input_patterns', {
"    \ 'tex': g:vimtex#re#deoplete
"    \})

">----| vim-sneak {{{2
let g:sneak#label = 1

">----| vimwiki {{{2
let g:vimwiki_list = [{
  \ 'syntax': 'markdown',
  \ 'ext': '.md',
  \ 'index': '_index',
  \ 'path': '/sdcard/Documents/vimwiki/content',
  \ 'path_html': '/sdcard/Documents/vimwiki/_site',
  \ 'template_ext': '.html',
  \ 'template_path': '/sdcard/Documents/vimwiki/templates/',
  \ }]

let g:vimwiki_diary_months = {
  \ 1: 'Janeiro', 2: 'Fevereiro', 3: 'Março',
  \ 4: 'Abril', 5: 'Maio', 6: 'Junho',
  \ 7: 'Julho', 8: 'Agosto', 9: 'Setembro',
  \ 10: 'Outubro', 11: 'Novembro', 12: 'Dezembro'
  \ }

  "\ 'auto_export': 1,
  "\ 'custom_wiki2html': 'wiki2html.sh',
""""""""""""""""""""""""""""""""""""""
"               GENERAL {{{1
""""""""""""""""""""""""""""""""""""""
" show hybrid line numbers
set number relativenumber

" configure line wrapping
set wrap

" highlith current line
set cursorline

" highlith column 80
set colorcolumn=80

" window scroll margin
set scrolloff=3

" search with smart case sensitiveness
set smartcase

" indent using 2 spaces
set expandtab     " convert TAB into spaces
set smarttab      " TAB respects 'tabstop', 'shiftwidth', and 'softtabstop'
set tabstop=2     " number of visual spaces per TAB
set softtabstop=2 " number of spaces in TAB when editing
set shiftwidth=2  " number of spaces to use for indent and unindent
set shiftround    " round indent to a multiple of 'shiftwidth'

" file type detection
set nocompatible
filetype indent on
filetype plugin on
syntax on

" save undo history
set undofile

" enable visual autocomplete for command menu
set wildmenu

" enhance searches
set incsearch " search as characters are typed
set hlsearch  " highlight matches

" set minimum window height and width
" this is useful to allow vim-maximizer to maximize fullscreen
set wmh=0
set wmw=0

" folding code
set foldenable
set foldmethod=indent " fold based on indent level
set foldlevel=0       " starting fold depth

" open splits towards the bottom right corner
set splitbelow
set splitright

" forces the tabline to always show
set showtabline=2

" allow to minimize unsaved buffers
set hidden

" don't warn about unsaved buffers when executing terminal command
set nowarn

" disable modeline to prevent misdetections
set nomodeline

" set all .tex files' filetype to latex
let g:tex_flavor = "latex"

" config concealing throught indentLine, since
" it overrides vim conceal options
let g:indentLine_concealcursor=""
let g:indentLine_conceallevel=2
" let g:tex_conceal='admgs'

" per file config
au FileType tex,markdown,vimwiki set textwidth=68
"au FileType vimwiki UltiSnipsAddFiletypes markdown
au BufReadPre init.vim,.zshrc,.tmux.conf set foldmethod=marker
au BufNewFile,BufRead *.neomuttrc,*.muttrc setfiletype neomuttrc

" set vertical split and fold characters
set fillchars=vert:\ ,fold:-

" show invisible characters
set list
set listchars=tab:→\ ,trail:⋅,extends:❯,precedes:❮
set showbreak=↪

" restore last cursors position when opening a buffer
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
""""""""""""""""""""""""""""""""""""""
"           KEYBINDINGS {{{1
""""""""""""""""""""""""""""""""""""""
" copy selected text in visual mode with CTRL-C
vnoremap <C-c> "+y

" move vertically by visual line
nnoremap j gj
nnoremap k gk

" maps gV to highlight last inserted text
nnoremap gV `[v`]

" Y to copy till end of line
nnoremap Y y$

" maps vim-maximizer plugin shortcut to match tmux
nnoremap <silent><C-w>z :MaximizerToggle<CR>
vnoremap <silent><C-w>z :MaximizerToggle<CR>gv
" inoremap <silent><C-w>z <C-o>:MaximizerToggle<CR>

" unhighlight last match
nnoremap <Esc> :noh<CR>:<backspace><esc>

" scroll text 3x faster with C-j and C-k
noremap <C-j> 3<C-e>
noremap <C-k> 3<C-y>

" del in insert mode
inoremap <C-d> <Del>

" ctrl-k cut from cursor to end of line in insert
inoremap <C-k> <space><Esc>C

" ctrl-a move to beginning of line and ctrl-e to
" accept copilot suggestions or move to end of line
inoremap <C-a> <Home>
imap <silent><script><expr> <C-e> copilot#Accept("\<End>")

" set exit terminal mode to esc key
" tnoremap <Esc> <C-\><C-n>

" ctags
" open the definition in a vertical split
map <C-w><A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" activate goyo with \z
nnoremap <silent> <leader>z <:Goyo<CR>:!tmux set -g status<CR><CR>

nnoremap <silent>  <leader>tl :call <SID>ToggleList('location')<CR>
nnoremap <silent>  <leader>tq :call <SID>ToggleList('quickfix')<CR>

" cscope
nnoremap <leader>ca :call CscopeFindInteractive(expand('<cword>'))<CR>
" s: Find this C symbol
nnoremap  <leader>cs :call CscopeFind('s', expand('<cword>'))<CR>
" g: Find this definition
nnoremap  <leader>cg :call CscopeFind('g', expand('<cword>'))<CR>
" d: Find functions called by this function
nnoremap  <leader>cd :call CscopeFind('d', expand('<cword>'))<CR>
" c: Find functions calling this function
nnoremap  <leader>cc :call CscopeFind('c', expand('<cword>'))<CR>
" t: Find this text string
nnoremap  <leader>ct :call CscopeFind('t', expand('<cword>'))<CR>
" e: Find this egrep pattern
nnoremap  <leader>ce :call CscopeFind('e', expand('<cword>'))<CR>
" f: Find this file
nnoremap  <leader>cf :call CscopeFind('f', expand('<cword>'))<CR>
" i: Find files #including this file
nnoremap  <leader>ci :call CscopeFind('i', expand('<cword>'))<CR>

" FZF
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <leader>fG :RG<CR>
nnoremap <leader>fl :BLines<CR>
nnoremap <leader>fL :Lines<CR>
nnoremap <leader>fm :Marks<CR>
nnoremap <leader>ft :Tags<CR>
""""""""""""""""""""""""""""""""""""""
"            FUNCTIONS {{{1
""""""""""""""""""""""""""""""""""""""
">----| function ToggleList() {{{
function! s:ToggleList(listType)
  if a:listType == 'quickfix'
    let l:openList = 'cw'
    let l:closeList = 'ccl'
    let l:listLen = len(getqflist())
  elseif a:listType == 'location'
    let l:openList = 'lw'
    let l:closeList = 'lcl'
    let l:listLen = len(getloclist(0))
  else
    echohl WarningMsg | echo "Invalid list type" | echohl None
    return
  endif

  let l:previousWindow = win_getid()
  exec(l:openList)
  let l:currentWindow = win_getid()

  if l:currentWindow == l:previousWindow
    if &buftype == 'quickfix' || l:listLen > 0
      exec(l:closeList)
    else
      echohl WarningMsg | echo "No " . a:listType . " list." | echohl None
    endif
  else
    call win_gotoid(l:previousWindow)
  endif
endfunction
" }}}
">----| function MyFiletype() {{{
function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction
" }}}
">----| function MyFileformat() {{{
function! MyFileformat()
  return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction
" }}}
""""""""""""""""""""""""""""""""""""""
"           COLORSCHEME {{{1
""""""""""""""""""""""""""""""""""""""
" enable 24-bit RGB color so we can use the gruvbox material
" instead of the original gruvbox variant
set termguicolors

" dark variant
set background=dark

" be sure to put this before 'colorscheme gruvbox-material'
" available value: 'hard', 'medium'(default), 'soft'
let g:gruvbox_material_background = 'medium'
" available value: 'original', 'material'(default), 'mix'
let g:gruvbox_material_palette = 'original'

" custom highlight when using git difftool
colorscheme gruvbox-material
hi DiffAdd      gui=none    guifg=#ccffcc       guibg=#6aa966
hi DiffChange   gui=none    guifg=#ffffff       guibg=#404040
hi DiffDelete   gui=bold    guifg=#ffcccc       guibg=#d06480
hi DiffText     gui=none    guifg=#ffffcc       guibg=#e08070
""""""""""""""""""""""""""""""""""""""

" github copilot complete with TAB
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
