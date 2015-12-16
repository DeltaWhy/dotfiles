set encoding=utf-8

" OS detection (must run first) {{{
if !exists('g:os')
  if has('win32') || has('win16') || has('win64')
    let g:os = 'Windows'
  elseif has('win32unix')
    let g:os = 'Cygwin'
  else
    let g:os = substitute(system('uname'), '\n', '', '')
  endif
endif
" }}}

" vim-sensible {{{
" From https://github.com/tpope/vim-sensible
if has('autocmd')
  filetype plugin indent on
endif
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif

" Use :help 'option' to see the documentation for the given option.

set autoindent
set backspace=indent,eol,start
set complete-=i
set smarttab

set nrformats-=octal

set ttimeout
set ttimeoutlen=100

set incsearch
" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

set laststatus=2
set ruler
set showcmd
set wildmenu

if !&scrolloff
  set scrolloff=1
endif
if !&sidescrolloff
  set sidescrolloff=5
endif
set display+=lastline

if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8
endif

if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j " Delete comment character when joining commented lines
endif

if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif

if &shell =~# 'fish$'
  set shell=/bin/bash
endif

set autoread
set fileformats+=mac

if &history < 1000
  set history=1000
endif
if &tabpagemax < 50
  set tabpagemax=50
endif
if !empty(&viminfo)
  set viminfo^=!
endif
set sessionoptions-=options

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
  set t_Co=16
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

inoremap <C-U> <C-G>u<C-U>
" }}}

" Other options {{{
let mapleader = ','
let maplocalleader = '\\'
set hidden
set hlsearch
set number
set shiftround
set splitbelow
set splitright
if has('mouse')
  set mouse=a
endif
" }}}

" Functions {{{

" Jump to the next or previous line that has the same level or a lower
" level of indentation than the current line.
"
" exclusive (bool): true: Motion is exclusive
" false: Motion is inclusive
" fwd (bool): true: Go to next line
" false: Go to previous line
" lowerlevel (bool): true: Go to line with lower indentation level
" false: Go to line with the same indentation level
" skipblanks (bool): true: Skip blank lines
" false: Don't skip blank lines
function! s:NextIndent(exclusive, fwd, lowerlevel, skipblanks)
  let line = line('.')
  let column = col('.')
  let lastline = line('$')
  let indent = indent(line)
  let stepvalue = a:fwd ? 1 : -1
  while (line > 0 && line <= lastline)
    let line = line + stepvalue
    if ( ! a:lowerlevel && indent(line) == indent ||
          \ a:lowerlevel && indent(line) < indent)
      if (! a:skipblanks || match(getline(line), '\v\S') >= 0)
        if (a:exclusive)
          let line = line - stepvalue
        endif
        exe line
        exe "normal " column . "|"
        return
      endif
    endif
  endwhile
endfunction

" For visual * and # mappings
function! s:VSetSearch()
  let temp = @@
  norm! gvy
  let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
  let @@ = temp
endfunction

" For <Leader>g
function! MagicGrep(word)
  if exists(':Ggrep')
    execute "Ggrep " . a:word
  elseif g:os == 'Windows'
    if match(&grepprg, '^findstr') >= 0
      execute "grep /s " . a:word . " *.*"
    elseif match(&grepprg, '^grep') >= 0
      execute "grep -rF " . a:word . " ."
    else
      echo 'Not available'
      return
    endif
  else
    execute "grep -rF " . a:word . " ."
  endif
endfunction

function! s:InstallVimPlug()
  let l:vimfiles = split(&runtimepath, ',')[0]
  let l:autoload = l:vimfiles . '/autoload'
  if g:os == 'Windows'
    if executable('powershell')
      if !isdirectory(l:autoload)
        call system('powershell -command md ' . shellescape(l:autoload))
      endif
      call system('powershell -command (New-Object Net.WebClient).DownloadFile(\"https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim\", ' . shellescape(shellescape(l:autoload . '/plug.vim')) . ')')
    else
      echom "Can't install vim-plug without Powershell"
      return
    endif
  else
    if !isdirectory(l:autoload)
      call system('mkdir -p ' . shellescape(l:autoload))
    endif
    if executable('wget')
      call system('wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -O ' . shellescape(l:autoload . '/plug.vim'))
    elseif executable('curl')
      call system('curl https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -o ' . shellescape(l:autoload . '/plug.vim'))
    else
      echom "Can't install vim-plug without wget or curl"
      return
    endif
  endif
  try
    call plug#begin()
    echom 'Successfully installed vim-plug'
  endtry
endfunction
" }}}

" Mappings {{{

" Miscellaneous
nnoremap <Leader>v :edit $MYVIMRC<CR>
nnoremap ]<Space> o<Esc>k
nnoremap [<Space> O<Esc>j
map <Leader>ew :e <C-R>=expand("%:p:h")
map Y y$

" Write with elevated privileges
if g:os != 'Windows' && g:os != 'Cygwin'
  cmap w!! w !sudo dd of=%
endif

" Visual * and #
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

" Magic grep
nnoremap <Leader>g :call MagicGrep(expand("<cword>"))<CR>
nnoremap <Leader>G :call MagicGrep(expand("<cWORD>"))<CR>
vnoremap <Leader>g :call MagicGrep(getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]])<CR>

" Indent movements
nnoremap <silent> [i :call <SID>NextIndent(0, 0, 0, 1)<CR>
nnoremap <silent> ]i :call <SID>NextIndent(0, 1, 0, 1)<CR>
nnoremap <silent> [I :call <SID>NextIndent(0, 0, 1, 1)<CR>
nnoremap <silent> ]I :call <SID>NextIndent(0, 1, 1, 1)<CR>
vnoremap <silent> [i <Esc>:call <SID>NextIndent(0, 0, 0, 1)<CR>m'gv''
vnoremap <silent> ]i <Esc>:call <SID>NextIndent(0, 1, 0, 1)<CR>m'gv''
vnoremap <silent> [I <Esc>:call <SID>NextIndent(0, 0, 1, 1)<CR>m'gv''
vnoremap <silent> ]I <Esc>:call <SID>NextIndent(0, 1, 1, 1)<CR>m'gv''
onoremap <silent> [i :call <SID>NextIndent(0, 0, 0, 1)<CR>
onoremap <silent> ]i :call <SID>NextIndent(0, 1, 0, 1)<CR>
onoremap <silent> [I :call <SID>NextIndent(1, 0, 1, 1)<CR>
onoremap <silent> ]I :call <SID>NextIndent(1, 1, 1, 1)<CR>
" }}}

" Autocommands {{{
if has('autocmd')
  autocmd BufWritePost _vimrc source $MYVIMRC
  autocmd BufWritePost .vimrc source $MYVIMRC
endif
" }}}

" OS specific settings {{{
if g:os == 'Windows'
  " Prefer MSYS grep
  if executable('grep')
    set grepprg=grep\ -nH
  endif

  if has('gui') || has('nvim')
    colors desert
    set encoding=utf-8
    set guifont=Consolas:h12
  else
    colors darkblue
  endif
elseif g:os == 'Darwin'
  if has('gui')
    set guifont=Menlo\ Regular:h14
  else
  endif
else " Unix
  if g:os == 'Cygwin'
    let &t_ti.="\e[1 q"
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
    let &t_te.="\e[0 q"
  endif
endif
" }}}

" GUI specific settings {{{
set guioptions-=m
set guioptions-=T
" }}}

" Plugins {{{
try
  call plug#begin()
catch
  echom 'Installing vim-plug'
  call s:InstallVimPlug()
endtry
if !exists('*plug#begin')
  echom "Couldn't install vim-plug"
else
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-sleuth'
  Plug 'kien/ctrlp.vim'
  Plug 'scrooloose/nerdtree' | nnoremap <silent> <Leader>n :NERDTreeToggle<CR>
  Plug 'tpope/vim-unimpaired'
  Plug 'tpope/vim-eunuch'
  Plug 'tpope/vim-endwise'
  Plug 'tpope/vim-dispatch'
  Plug 'bling/vim-airline'
  Plug 'mhinz/vim-startify'
  Plug 'pbrisbin/vim-mkdir'
  Plug 'tpope/vim-rails', { 'for': 'ruby' }
  call plug#end()
endif
" }}}
" vim:sw=2 sts=2 et foldmethod=marker
