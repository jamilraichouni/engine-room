vim.o.expandtab = true -- blanks instead of tab
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4

-- treesitter
vim.treesitter.start()
vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo[0][0].foldmethod = "expr"
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

