if v:progname =~? "evim"
  finish
endif

set nocompatible
set encoding=utf-8 " Necessary to show Unicode glyphs

runtime vundle.vim
let g:slime_target="tmux"
let g:slime_paste_file=tempname()
let g:org_agenda_files = ['~/Dropbox/VimNotes/org/*.org']
let g:rails_projections = {
    \ "spec/factories/*.rb": {
    \   "command": "factory",
    \   "related": "app/models/%i.rb",
    \   "affinity": "collection" }}

set backspace=indent,eol,start
set history=50
set wildmenu
set autoindent
set smartindent
set expandtab
set tabstop=8
set shiftwidth=4
set sts=4
set incsearch
set hlsearch
set shiftround
set splitbelow
set splitright
if has('mouse')
  set mouse=a
endif
if has("autocmd")
  filetype plugin indent on
  autocmd bufwritepost .vimrc source $MYVIMRC
  autocmd BufNewFile,BufRead *.rb setlocal sw=2 sts=2 et
  autocmd BufNewFile,BufRead *.slim setlocal sw=2 sts=2 et
  autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > 1024*1024 | set eventignore+=FileType | setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 | else | set eventignore-=FileType | endif
endif " has("autocmd")

runtime appearance.vim
runtime commands.vim
