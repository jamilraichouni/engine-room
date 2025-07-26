vim.fn.matchadd("Constant", "^<<< assistant")
vim.fn.matchadd("PreProc", "^>>> system")
vim.fn.matchadd("String", "^>>> user\\|^>>> include\\|^>>> exec")
vim.fn.matchadd("Title", "^# .*\\|^## .*\\|^### .*\\|^#### .*\\|^##### .*\\|^###### .*", -1)
vim.opt_local.wrap = true
