-- OS detection {{{
if not vim.g.os then
  if vim.fn.has('win32') ~= 0 or vim.fn.has('win16') ~= 0 or vim.fn.has('win64') ~= 0 then
    vim.g.os = 'Windows'
  elseif vim.fn.has('win32unix') ~= 0 then
    vim.g.os = 'Cygwin'
  else
    vim.g.os = vim.fn.substitute(vim.fn.system('uname'), '\n', '', '')
  end
end
-- }}}

-- Bootstrap lazy.nvim {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- }}}

-- Functions {{{
vim.cmd([[
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
function! NextIndent(exclusive, fwd, lowerlevel, skipblanks)
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
function! VSetSearch()
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
]])
-- }}}

-- General options {{{
vim.opt.encoding='utf-8'
vim.g.mapleader = ','
vim.g.maplocalleader = '\\'
vim.opt.termguicolors = true
vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.number = true
vim.opt.shiftround = true
vim.opt.splitbelow = true
vim.opt.splitright = true
if vim.fn.has('mouse') then
  vim.opt.mouse = 'a'
end
vim.opt.inccommand = 'nosplit'
vim.opt.textwidth = 119
vim.opt.formatoptions:remove('t')
vim.opt.colorcolumn = '+1'
-- }}}

-- Mappings {{{
vim.keymap.set('n', '<Leader>j', ':0,$!jq .<CR>', { desc = 'format with jq' })
vim.keymap.set('v', '<Leader>j', ":'<,'>!jq .<CR>", { desc = 'format with jq' })
vim.keymap.set('n', '<Leader>J', ':0,$!jq -S .<CR>', { desc = 'format with jq (sort keys)' })
vim.keymap.set('v', '<Leader>J', ":'<,'>!jq -S .<CR>", { desc = 'format with jq (sort keys)' })
vim.keymap.set('n', '<Leader>v', ':edit $MYVIMRC<CR>', { desc = 'edit init.lua' })
vim.keymap.set('n', ']<Space>', 'o<Esc>k', { desc = 'insert blank line below' })
vim.keymap.set('n', '[<Space>', 'O<Esc>j', { desc = 'insert blank line above' })
vim.keymap.set('', '<Leader>ew', ':e <C-R>=expand("%:p:h")', { desc = 'edit parent directory' })
vim.keymap.set('', 'Y', 'y$')
vim.keymap.set('n', '<Leader>y', ':0,$y +<CR>', { desc = 'copy whole file to clipboard' })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
vim.keymap.set('n', '<Leader>p', ':14split term://ipython<CR>', { desc = 'ipython terminal' })
vim.keymap.set('n', '<Leader>t', function ()
  vim.cmd('14split')
  local ok, result = pcall(vim.cmd, 'buf term:')
  if not ok then
    vim.cmd('e term://$SHELL')
  end
end, { desc = 'toggle terminal' })
if vim.g.os ~= 'Windows' and vim.g.os ~= 'Cygwin' then
  vim.keymap.set('c', 'w!!', 'w !sudo dd of=%')
end
vim.keymap.set('v', '*', ':<C-u>call VSetSearch()<CR>//<CR>')
vim.keymap.set('v', '#', ':<C-u>call VSetSearch()<CR>??<CR>')

vim.keymap.set('n', '<Leader>g', ':call MagicGrep(expand("<cword>"))<CR>', { desc = 'grep word' })
vim.keymap.set('n', '<Leader>G', ':call MagicGrep(expand("<cWORD>"))<CR>', { desc = 'grep WORD' })
vim.keymap.set('v', '<Leader>g', ':call MagicGrep(getline("\'<")[getpos("\'<")[2]-1:getpos("\'>")[2]])<CR>', { desc = 'grep selection' })

vim.keymap.set({'n','o'}, '[i', ':call NextIndent(0, 0, 0, 1)<CR>', { silent = true, desc = 'move by indent' })
vim.keymap.set({'n','o'}, ']i', ':call NextIndent(0, 1, 0, 1)<CR>', { silent = true, desc = 'move by indent' })
vim.keymap.set({'n','o'}, '[I', ':call NextIndent(0, 0, 1, 1)<CR>', { silent = true, desc = 'move by indent' })
vim.keymap.set({'n','o'}, ']I', ':call NextIndent(0, 1, 1, 1)<CR>', { silent = true, desc = 'move by indent' })
vim.keymap.set('v', '[i', "<Esc>:call NextIndent(0, 0, 0, 1)<CR>m'gv''", { silent = true, desc = 'move by indent' })
vim.keymap.set('v', ']i', "<Esc>:call NextIndent(0, 1, 0, 1)<CR>m'gv''", { silent = true, desc = 'move by indent' })
vim.keymap.set('v', '[I', "<Esc>:call NextIndent(0, 0, 1, 1)<CR>m'gv''", { silent = true, desc = 'move by indent' })
vim.keymap.set('v', ']I', "<Esc>:call NextIndent(0, 1, 1, 1)<CR>m'gv''", { silent = true, desc = 'move by indent' })
-- }}}

-- Autocommands {{{
local mygroup = vim.api.nvim_create_augroup('vimrc', { clear = true })
--vim.api.nvim_create_autocmd('BufWritePost', { pattern = 'init.lua', command = 'source $MYVIMRC', group = mygroup })
vim.api.nvim_create_autocmd('TermOpen', { pattern = '*', command = 'startinsert', group = mygroup })
vim.api.nvim_create_autocmd({'BufNewFile','BufRead'}, { pattern = {'COMMIT_EDITMSG', 'MERGE_MSG'}, command = 'set bufhidden=delete', group = mygroup })
vim.api.nvim_create_autocmd({'BufNewFile','BufRead'}, { pattern = {'*.state'}, command = 'set ft=json', group = mygroup })
vim.api.nvim_create_autocmd('GUIEnter', { pattern = '*', callback = function ()
  vim.opt.guioptions:remove('m')
  vim.opt.guioptions:remove('T')
end, group = mygroup })
vim.api.nvim_create_autocmd('UIEnter', { pattern = '*', callback = function ()
  vim.cmd('redraw!')
end, group = mygroup })
-- }}}

-- OS specific settings {{{
if vim.g.os == 'Windows' then
  if vim.fn.executable('grep') then
    vim.o.grepprg='grep -nH'
  end
  vim.cmd('colors desert')
  vim.o.encoding='utf-8'
  vim.o.guifont='Consolas:h12'
elseif vim.g.os == 'Darwin' then
  vim.o.guifont='Menlo Regular:h14'
else
  vim.o.encoding='utf-8'
  vim.o.guifont='Liga Roboto Mono:h12'
  vim.api.nvim_create_autocmd('GUIEnter', { pattern = '*', command = 'colors base16' })
  vim.cmd('colors base16')
  if vim.g.os == 'Cygwin' then
    vim.cmd('let &t_ti.="\\e[1 q"')
    vim.cmd('let &t_SI.="\\e[5 q"')
    vim.cmd('let &t_EI.="\\e[1 q"')
    vim.cmd('let &t_te.="\\e[0 q"')
  end
  vim.g.python3_host_prog="/usr/bin/python3"
end
-- vim.g.neovide_floating_blur_amount_x = 2.0
-- vim.g.neovide_floating_blur_amount_y = 2.0
-- vim.g.neovide_floating_shadow = true
vim.g.neovide_position_animation_length = 0.15
vim.g.neovide_scroll_animation_length = 0.1
vim.g.neovide_transparency = 0.95
-- }}}

-- Plugins {{{
require("lazy").setup({
  'tpope/vim-sensible',
  'tpope/vim-repeat',
  'tpope/vim-surround',
  'tpope/vim-fugitive',
  'shumphrey/fugitive-gitlab.vim',
  'tpope/vim-sleuth',
  --'kien/ctrlp.vim',
  { 'scrooloose/nerdtree', keys = { {'<Leader>n', '<cmd>NERDTreeToggle<cr>', silent = true } } },
  'tpope/vim-unimpaired',
  'tpope/vim-eunuch',
  'tpope/vim-endwise',
  'tpope/vim-dispatch',
  { 'vim-airline/vim-airline', config = function()
    vim.g['airline#extensions#tabline#enabled'] = 1
    vim.g['airline#extensions#poetv#enabled'] = 1
  end },
  -- { 'mhinz/vim-startify', config = function()
  --   vim.g.startify_change_to_dir = 0
  --   vim.g.startify_change_to_vcs_root = 1
  -- end },
  { 'neoclide/coc.nvim', branch = 'release', config = function()
    vim.keymap.set('i', '<c-space>', 'coc#refresh()', { silent = true, expr = true })
    -- Use K to show documentation in preview window
    function _G.show_docs()
      local cw = vim.fn.expand('<cword>')
      if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
      elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
      else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
      end
    end
    vim.keymap.set("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})
    vim.keymap.set("n", "gd", "<Plug>(coc-definition)", {silent = true})
    vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
    vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", {silent = true})
    vim.keymap.set("n", "gr", "<Plug>(coc-references)", {silent = true})
    -- vim.keymap.set("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
  end },
  { 'petobens/poet-v', config = function ()
    vim.g.poetv_executables = {'poetry'}
    vim.g.poetv_auto_activate = 1
  end },
  { 'Shougo/deoplete.nvim', config = function()
    vim.g['deoplete#enable_at_startup'] = 1
  end },
  { 'deoplete-plugins/deoplete-jedi', dependencies = { 'Shougo/deoplete.nvim' } },
  'mtth/scratch.vim',
  'neoclide/jsonc.vim',
  'schickling/vim-bufonly',
  'jvirtanen/vim-hcl',
  'arcticicestudio/nord-vim',
  { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
  -- { 'junegunn/fzf.vim', config = function()
  --   vim.keymap.set('n', '<C-P>', ':Files<CR>')
  -- end },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({})
    end
  },
  { 'folke/which-key.nvim', event = 'VeryLazy', init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end, opts = {} },
  { 'lukas-reineke/indent-blankline.nvim', main = "ibl", opts = {
    indent = { char = '▏' }
  } },
  { 'nvim-treesitter/nvim-treesitter', build = function() vim.cmd('TSUpdate') end, config = function()
  require'nvim-treesitter.configs'.setup {
    ensure_installed = { 'lua', 'vim', 'vimdoc', 'python', 'json', 'bash', 'comment', 'css', 'devicetree', 'diff', 'dockerfile', 'git_config', 'gitattributes', 'gitcommit', 'gitignore', 'go', 'hcl', 'html', 'java', 'javascript', 'jq', 'jsonc', 'make', 'markdown_inline', 'rust', 'rst', 'scss', 'sql', 'ssh_config', 'terraform', 'toml', 'tsv', 'typescript', 'yaml', 'csv' },
    auto_install = false,
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
    },
  }
end },
{ 'https://gitlab.com/HiPhish/rainbow-delimiters.nvim', config = function()
  local rainbow_delimiters = require 'rainbow-delimiters'
  vim.g.rainbow_delimiters = {
    strategy = {
      [''] = rainbow_delimiters.strategy['global'],
    },
    query = {
      [''] = 'rainbow-delimiters',
      lua = 'rainbow-blocks',
    },
    highlight = {
      'RainbowDelimiterRed',
      'RainbowDelimiterYellow',
      'RainbowDelimiterBlue',
      'RainbowDelimiterOrange',
      'RainbowDelimiterGreen',
      'RainbowDelimiterViolet',
      'RainbowDelimiterCyan',
    },
  }
end },
'MTDL9/vim-log-highlighting',
'towolf/vim-helm',
{ 'ii14/neorepl.nvim', command = 'Repl' },
{ 'folke/snacks.nvim', opts = {
  bigfile = { enabled = true },
  notifier = { enabled = true },
  dashboard = {
    sections = {
        { section = "header" },
        -- { section = "terminal", cmd = "fortune -s | cowsay", hl = "header", padding = 1, indent = 8 },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
  }},
  { 'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    config = function()
      local ls = require('luasnip')
      vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
      vim.keymap.set({'i','s'}, "<C-L>", function() ls.jump(1) end, {silent = true})
      vim.keymap.set({'i','s'}, "<C-J>", function() ls.jump(-1) end, {silent = true})

      vim.keymap.set({'i', 's'}, "<C-E>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, {silent = true})
      require('luasnip.loaders.from_vscode').lazy_load()
      require('snippets')
    end,
  },
{
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  ft = { 'org' },
  config = function()
    -- Setup orgmode
    require('orgmode').setup({
      org_agenda_files = '~/org/**/*',
      org_default_notes_file = '~/org/index.org',
    })

    -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
    -- add ~org~ to ignore_install
    -- require('nvim-treesitter.configs').setup({
    --   ensure_installed = 'all',
    --   ignore_install = { 'org' },
    -- })
  end,
}
})
-- }}}

-- vim:sw=2 sts=2 et foldmethod=marker
