vim.opt.background = "dark" -- Tell vim that the terminal has a dark background
vim.opt.hidden = true       -- allow switching buffers without saving

-- indentation
vim.opt.expandtab = true -- blanks instead of tab
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

vim.opt.colorcolumn = "80"
vim.opt.shell = "/bin/zsh"
vim.opt.fillchars = "diff:-"
vim.opt.completeopt = "menuone,noinsert,noselect,preview"
vim.opt.diffopt = "internal,filler,closeoff,vertical"
vim.opt.foldlevelstart = 10
vim.opt.foldmethod = "expr"
vim.opt.guicursor = "i-t-c-ci-ve:ver25-blinkon500-blinkoff500,n-v:block-blinkon500-blinkoff500"
-- search:
vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true  -- become case-sensitive if you type uppercase chars

vim.opt.list = true
vim.opt.listchars = "tab:→  ,trail:·,extends:>,precedes:<" -- highlight trailing whitespace
vim.opt.mouse = "a"
vim.opt.backup = false
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.swapfile = false
vim.opt.wrap = false
vim.opt.writebackup = false

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true -- highlight current line

vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.wildmenu = true                    -- display all matching files when we tab complete
vim.opt.wildignore = "**/.git/**,**/.venv/**,!.*"
vim.opt.shortmess = vim.o.shortmess .. "S" -- Don't show search count since we use it in feline

