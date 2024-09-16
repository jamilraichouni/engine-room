-- line numbers
vim.keymap.set("n", "<leader>a", "<cmd>setlocal norelativenumber number<cr>", { silent = true })
vim.keymap.set("n", "<leader>r", "<cmd>setlocal relativenumber<cr>", { silent = true })
vim.keymap.set("n", "<leader>n", "<cmd>setlocal norelativenumber nonumber<cr>", { silent = true })
vim.keymap.set("n", "<leader>ö", "<cmd>nohlsearch<cr>", { silent = true })
-- resize window
vim.keymap.set("n", "<left>", "<cmd>vertical resize -5<cr>", { silent = true })
vim.keymap.set("n", "<right>", "<cmd>vertical resize +5<cr>", { silent = true })
vim.keymap.set("n", "<up>", "<cmd>resize +5<cr>", { silent = true })
vim.keymap.set("n", "<down>", "<cmd>resize -5<cr>", { silent = true })

-- edit specific files
vim.keymap.set("n", "<leader>Lsp", "<cmd>e ~/.config/nvim/lua/plugins/lsp.lua<cr>", { silent = true })
vim.keymap.set("n", "<leader>Jdt", "<cmd>e ~/.config/nvim/ftplugin/java.lua<cr>", { silent = true })

-- dedent in insert mode
vim.keymap.set("i", "<S-Tab>", "<C-d>")

-- Disable arrow keys in visual mode
vim.keymap.set("v", "<left>", "<nop>")
vim.keymap.set("v", "<right>", "<nop>")
vim.keymap.set("v", "<up>", "<nop>")
vim.keymap.set("v", "<down>", "<nop>")

-- exit insert mode of terminal as it is in vim
vim.keymap.set("t", "<c-w>N", "<c-\\><c-n>")

-- unfold and on top
vim.keymap.set("n", "<leader>zo", "zo z<cr>", { silent = true })
vim.keymap.set("n", "<leader>zO", "zO z<cr>", { silent = true })

-- diff (do -> obtain, dp -> put)
vim.keymap.set("n", "<leader>dt", "<cmd>windo diffthis<cr>", { silent = true })
vim.keymap.set("n", "<leader>do", "<cmd>windo diffoff<cr>", { silent = true })

-- edit specific files {{{
vim.keymap.set("n", "<leader>Init", "<cmd>e ~/.config/nvim/init.lua<cr>", { silent = true })
vim.keymap.set("n", "<leader>Plug", "<cmd>Oil ~/.config/nvim/lua/plugins<cr>", { silent = true })
vim.keymap.set("n", "<leader>Cfg", "<cmd>Oil ~/.config/nvim<cr>", { silent = true })
vim.keymap.set("n", "<leader>Doc", "<cmd>tabnew $DOT/JARDOC.md<cr>", { silent = true })

-- working times
vim.keymap.set("n", "<leader>Ewt",
    "<cmd>tabnew ~/dev/github/working-times/data/working_times.csv<bar>TSBufDisable highlight<cr>", { silent = true })
-- }}}

-- current file attrs with and without line number {{{

-- relative
vim.keymap.set("n", "<leader>er", "<cmd>let @\" = fnamemodify(expand('%'), ':.')<cr>")

-- relative with line number
vim.keymap.set("n", "<leader>erl", "<cmd>let @\" = fnamemodify(expand('%'), ':.') . ':' . line('.')<cr>")

-- absolute
vim.keymap.set("n", "<leader>ea", "<cmd>let @\" = expand('%:p')<cr>")

-- absolute with line number
vim.keymap.set("n", "<leader>eal", "<cmd>let @\" = expand('%:p') . ':' . line('.')<cr>")

-- filename
vim.keymap.set("n", "<leader>en", "<cmd>let @\" = fnamemodify(expand('%:t'), ':.')<cr>")
-- }}}

-- aliases {{{
-- htop
vim.keymap.set("n", "<leader>Hb", "<cmd>terminal htop<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ht", "<cmd>tabedit term://htop<bar>startinsert<cr>")
vim.keymap.set("n", "<leader>Hh", "<cmd>vnew <bar> terminal htop<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Hj", "<cmd>belowright new <bar> terminal htop<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Hk", "<cmd>new <bar> terminal htop<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Hl", "<cmd>belowright vnew <bar> terminal htop<cr><cmd>startinsert<cr>")

-- ipython
vim.keymap.set("n", "<leader>Ib", "<cmd>terminal ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>It", "<cmd>tabedit term://ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ih", "<cmd>vnew <bar> terminal ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ij", "<cmd>belowright new <bar> terminal ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ik", "<cmd>new <bar> terminal ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Il", "<cmd>belowright vnew <bar> terminal ipython<cr><cmd>startinsert<cr>")

-- python
vim.keymap.set("n", "<leader>Pb", "<cmd>terminal python<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Pt", "<cmd>tabedit term://python<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ph", "<cmd>vnew <bar> terminal python<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Pj", "<cmd>belowright new <bar> terminal python<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Pk", "<cmd>new <bar> terminal python<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Pl", "<cmd>belowright vnew <bar> terminal python<cr><cmd>startinsert<cr>")

-- terminal
vim.keymap.set("n", "<leader>Tb", "<cmd>terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Tt", "<cmd>tabedit term://zsh<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Th", "<cmd>vnew +terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Tj", "<cmd>belowright new +terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Tk", "<cmd>new +terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Tl", "<cmd>belowright vnew +terminal<cr><cmd>startinsert<cr>")
-- }}}
