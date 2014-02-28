set ruler
set showcmd

syntax on
set laststatus=2   " Always show the statusline
set number
set t_Co=256

if has("gui_running")
  set background=dark
  colorscheme solarized
endif

highlight RedundantSpaces term=standout ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t/ "\ze sets end of match so only spaces highlighted
"use :set list! to toggle visible whitespace on/off
set listchars=tab:>-,trail:.,extends:>
syntax match tab /\t/
hi tab gui=underline guifg=blue ctermbg=blue

set guioptions-=m
set guioptions-=T

if has("macunix")
  set guifont=Menlo\ Regular:h14
else
  set guifont=Ubuntu\ Mono\ 13
  "set guifont=Inconsolata-dz\ Medium\ 12
endif

set display=lastline

