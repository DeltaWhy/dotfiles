filetype off

let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
if !filereadable(vundle_readme)
echo "Installing Vundle.."
echo ""
silent !mkdir -p ~/.vim/bundle
silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
let iCanHazVundle=0
endif
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

"Add your bundles here
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-bundler'
Bundle 'tpope/vim-rake'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-ragtag'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-commentary'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-abolish'
Bundle 'tpope/vim-eunuch'
Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-dispatch'
Bundle 'jpalardy/vim-slime'
Bundle 'kien/ctrlp.vim'
Bundle 'spiiph/vim-space'
Bundle 'pangloss/vim-javascript'
Bundle 'briancollins/vim-jst'
"Bundle 'Lokaltog/vim-powerline'
Bundle 'bling/vim-airline'
Bundle 'altercation/vim-colors-solarized'
Bundle 'slim-template/vim-slim'
Bundle 'kchmck/vim-coffee-script'
Bundle 'bkad/CamelCaseMotion'
Bundle 'vim-scripts/argtextobj.vim'
Bundle 'skwp/vim-rspec'
Bundle 'tpope/vim-markdown'
Bundle 'derekwyatt/vim-scala'
Bundle 'jceb/vim-orgmode'
Bundle 'vim-scripts/utl.vim'
Bundle 'mattn/calendar-vim'
Bundle 'scrooloose/syntastic'
Bundle 'Shougo/vimproc.vim'
Bundle 'Shougo/vimshell.vim'
Bundle 'mhinz/vim-startify'

if iCanHazVundle == 0
echo "Installing Bundles, please ignore key map error messages"
echo ""
:BundleInstall
endif

"let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
"let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
"let g:airline_symbols.linenr = '␊'
let g:airline_symbols = {}
let g:airline_symbols.linenr = '␤'
"let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
"let g:airline_symbols.paste = 'Þ'
"let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

let g:startify_session_autoload = 1
let g:startify_change_to_vcs_root = 1
let g:startify_skiplist = [
    \ 'COMMIT_EDITMSG',
    \ $VIMRUNTIME .'/doc',
    \ 'bundle/.*/doc'
    \ ]
