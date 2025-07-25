vim.fn.matchadd("Constant", "^<<< assistant")
vim.fn.matchadd("PreProc", "^>>> system")
vim.fn.matchadd("String", "^>>> user\\|^>>> include\\|^>>> exec")
vim.fn.matchadd("Title", "^# .*\\|^## .*\\|^### .*\\|^#### .*\\|^##### .*\\|^###### .*")
vim.opt_local.wrap = true
