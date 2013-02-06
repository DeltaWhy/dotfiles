if v:progname =~? "evim"
  finish
endif

set nocompatible
set encoding=utf-8 " Necessary to show Unicode glyphs

runtime vundle.vim

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
if has('mouse')
  set mouse=a
endif
if has("autocmd")
  filetype plugin indent on
  autocmd bufwritepost .vimrc source $MYVIMRC
endif " has("autocmd")

runtime appearance.vim
runtime commands.vim
