vim.o.background = "dark" -- Tell vim that the terminal has a dark background
vim.o.hidden = true       -- allow switching buffers without saving

-- indentation
vim.o.expandtab = true -- blanks instead of tab
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4

vim.o.shell = "/bin/zsh"
vim.o.fillchars = "diff:-"
vim.o.colorcolumn = "79"
vim.o.completeopt = "menuone,noinsert,noselect,preview"
vim.o.foldmethod = "expr"

-- search:
vim.o.ignorecase = true -- case insensitive search
vim.o.smartcase = true  -- become case-sensitive if you type uppercase chars

vim.o.list = true
vim.o.listchars = "tab:→  ,trail:·,extends:>,precedes:<" -- highlight trailing whitespace
vim.o.mouse = "a"
vim.o.backup = false
vim.o.showmode = false
vim.o.swapfile = false
vim.o.wrap = false
vim.o.writebackup = false

-- line numbers
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true -- highlight current line

vim.o.termguicolors = true
vim.o.undofile = true
vim.o.wildmenu = true                    -- display all matching files when we tab complete
vim.o.shortmess = vim.o.shortmess .. "S" -- Don't show search count since we use it in feline
