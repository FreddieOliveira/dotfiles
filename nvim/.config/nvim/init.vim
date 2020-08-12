"            PLUGINS {{{1
""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.local/share/nvim/plugged')

Plug 'deoplete-plugins/deoplete-clang' " deoplete provider for C/C++
Plug 'Shougo/deoplete.nvim'            " autocompletion framework
Plug 'junegunn/goyo.vim'               " distraction free mode
Plug 'sainnhe/gruvbox-material'        " colorscheme
Plug 'Yggdroot/indentLine'             " draw indent guides (not so good)
Plug 'itchyny/lightline.vim'           " status bar
Plug 'taohexxx/lightline-buffer'       " lightline top bar plugin
Plug 'junegunn/limelight.vim'          " text color dimmer (used with goyo)
Plug 'neomake/neomake'                 " code linting
Plug 'SirVer/ultisnips'                " snippets framework
Plug 'ludovicchabant/vim-gutentags'    " ctags auto generator
Plug 'skywind3000/gutentags_plus'      " cscope useful shortcuts
Plug 'szw/vim-maximizer'               " tmux C-z
Plug 'terryma/vim-multiple-cursors'    " sublime like multi cursors
Plug 'honza/vim-snippets'              " ultisnips provider
Plug 'lervag/vimtex'                   " LaTeX integration
Plug 'justinmk/vim-sneak'              " quick cursor jump around
Plug 'ryanoasis/vim-devicons'          " file type icons
Plug 'junegunn/fzf'                    " fzf integration
Plug 'junegunn/fzf.vim'                " fzf integration
Plug 'vimwiki/vimwiki'
"Plug 'amix/vim-zenroom2'               " .md colorscheme when goyo is on
"Plug 'iamcco/markdown-preview.nvim'    " web browser .md preview
"Plug 'Valloric/YouCompleteMe'          " autocompletion

call plug#end()
""""""""""""""""""""""""""""""""""""""
"           PLUGINS CONFIG {{{1
""""""""""""""""""""""""""""""""""""""
">----| bufferline {{{2
let g:lightline_buffer_enable_devicons = 1
let g:lightline_buffer_show_bufnr = 1
let g:lightline_buffer_fname_mod = ':t'
let g:lightline_buffer_separator_right_icon=''
let g:lightline_buffer_separator_left_icon=''

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
  \     'left': [['tabStatus'], ['bufferall']],
  \     'right': [['close']]
  \   },
  \   'component_expand': {
  \     'bufferall': 'lightline#buffer#bufferall',
  \   },
  \   'component_type': {
  \     'bufferall': 'tabsel',
  \   },
  \   'component_function': {
  \     'windowNumber': 'winnr',
  \     'windowMaximized': 'IsMaximized',
  \     'tabStatus': 'TabStatus',
  \   },
  \   'component_raw': {
  \     'bufferall': 1
  \   },
  \   'separator': {
  \     'left': "", 'right': ""
  \   },
  \   'subseparator': {
  \     'left': "", 'right': ""
  \   },
  \ }

">----| limelight {{{2
autocmd! User GoyoEnter Limelight 0.8
autocmd! User GoyoLeave Limelight!

">----| neomake {{{2
" on changes in normal mode and when writing
" to a buffer, after 500ms of delay
call neomake#configure#automake('nw', 500)
" open quickfix/location list window when error is detected
let g:neomake_open_list = 2
" use gcc for C linting
let g:neomake_c_enabled_makers = ['gcc']
" disable linting on TeX files
let g:neomake_tex_enabled_makers = []
let g:neomake_error_sign = {
    \ 'text': '>>',
    \ 'texthl': 'ErrorMsg',
    \ }
let g:neomake_warning_sign = {
    \   'text': '‼',
    \   'texthl': 'WarningMsg',
    \ }

">----| tag {{{2
let g:gutentags_enabled=0

">----| ultilsnips {{{2
let g:UltiSnipsExpandTrigger="<Tab>"
let g:UltiSnipsJumpForwardTrigger="<Tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"

">----| vimtex {{{2
" configure it to use Okular as the PDF viewer
" let g:vimtex_view_general_viewer = 'okular'
" let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
" let g:vimtex_view_general_options_latexmk = '--unique'
" configure it to use deoplete
call deoplete#custom#var('omni', 'input_patterns', {
    \ 'tex': g:vimtex#re#deoplete
    \})

">----| vim-sneak {{{2
let g:sneak#label = 1

">----| vimwiki {{{2
let g:vimwiki_list = [{
  \ 'auto_export': 1,
  \ 'custom_wiki2html': 'wiki2html.sh',
  \ 'ext': '.md',
  \ 'index': '_index',
  \ 'path': '/sdcard/Documents/vimwiki/content',
  \ 'path_html': '/sdcard/Documents/vimwiki/_site',
  \ 'syntax': 'markdown',
  \ 'template_ext': '.html',
  \ 'template_path': '/sdcard/Documents/vimwiki/templates/',
\}]

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

" set all .tex files' filetype to latex
let g:tex_flavor = "latex"

" config concealing throught indentLine, since
" it overrides vim conceal options
let g:indentLine_concealcursor=""
let g:indentLine_conceallevel=2
" let g:tex_conceal='admgs'

" per file config
au FileType tex,markdown,vimwiki set textwidth=68
au FileType vimwiki UltiSnipsAddFiletypes markdown
au BufReadPre init.vim,.zshrc set foldmethod=marker
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
nnoremap <esc> :noh<CR>:<backspace><esc>

" scroll text 3x faster with C-j and C-k
noremap <C-j> 3<C-e>
noremap <C-k> 3<C-y>

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

" del in insert mode
inoremap <C-d> <Del>
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
">----| function IsMaximized() {{{
function! IsMaximized()
  if exists('t:maximizer_sizes') && t:maximizer_sizes.after == winrestcmd()
    return 'Z'
  else
    return ''
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
">----| function TabStatus() {{{
function! TabStatus()
  return tabpagenr() . '/' . tabpagenr("$")
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

colorscheme gruvbox-material
""""""""""""""""""""""""""""""""""""""
