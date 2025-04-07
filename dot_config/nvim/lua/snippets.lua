local ls = require('luasnip')
local s = ls.s
local fmt = require('luasnip.extras.fmt').fmt
local i = ls.insert_node
local rep = require('luasnip.extras').rep
local t = ls.text_node

ls.add_snippets('lua', {
  ls.parser.parse_snippet('km', 'vim.keymap.set("$1", "$2", {silent = true})'),
  ls.parser.parse_snippet('nmap', 'vim.keymap.set("n", "$1", {silent = true})'),
  ls.parser.parse_snippet('imap', 'vim.keymap.set("i", "$1", {silent = true})'),
  ls.parser.parse_snippet('vmap', 'vim.keymap.set("v", "$1", {silent = true})'),
  --ls.parser.parse_snippet('req', "local $1 = require('$1')"),
  s('req', fmt("local {} = require('{}')", {
    rep(1),
    i(1)
  }))
}, {default_priority = 1001})

ls.add_snippets('python', {
}, {default_priority = 1001})
