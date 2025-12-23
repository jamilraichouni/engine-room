vim.opt_local.foldmethod = "marker"
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- treesitter
vim.treesitter.start()
vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo[0][0].foldmethod = "expr"
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

