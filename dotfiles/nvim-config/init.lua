vim.cmd.colorscheme("habamax")
vim.cmd("filetype plugin indent on")

require("init.autocmd")
require("init.function")
require("init.global")
require("init.highlight")
require("init.keymap")
require("init.lazy")
require("init.lsp")
require("init.option")
require("init.diagnostic")
require("init.usercommand")

vim.cmd.set("foldtext=g:fold_text()")
require("mason-registry").update()

