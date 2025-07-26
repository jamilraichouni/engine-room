-- line numbers
vim.keymap.set("n", "<leader>a", "<cmd>setlocal norelativenumber number<cr>", { silent = true })
vim.keymap.set("n", "<leader>r", "<cmd>setlocal relativenumber<cr>", { silent = true })
vim.keymap.set("n", "<leader>n", "<cmd>setlocal norelativenumber nonumber<cr>", { silent = true })
vim.keymap.set("n", "<leader><leader>", "<cmd>nohlsearch<cr>", { silent = true })
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

-- diff keymaps (do -> obtain, dp -> put)
vim.keymap.set("n", "<leader>dt", "<cmd>windo diffthis<cr>", { silent = true })
vim.keymap.set("n", "<leader>do", "<cmd>windo diffoff<cr>", { silent = true })

-- edit specific files {{{
vim.keymap.set("n", "<leader>Auto", "<cmd>e ~/.config/nvim/lua/init/autocmd.lua<cr>", { silent = true })
vim.keymap.set("n", "<leader>Init", "<cmd>e ~/.config/nvim/init.lua<cr>", { silent = true })
vim.keymap.set("n", "<leader>Key", "<cmd>e ~/.config/nvim/lua/init/keymap.lua<cr>", { silent = true })
vim.keymap.set("n", "<leader>Plug", "<cmd>Oil ~/.config/nvim/lua/plugins<cr>", { silent = true })
vim.keymap.set("n", "<leader>Cfg", "<cmd>Oil ~/.config/nvim<cr>", { silent = true })
vim.keymap.set("n", "<leader>Doc", "<cmd>tabnew $DOT/JARDOC.md<cr>", { silent = true })

-- working times
vim.keymap.set("n", "<leader>Ewt",
    "<cmd>tabnew ~/dev/github/working-times/data/working_times.csv<cr><cmd>TSBufDisable highlight<cr>", { silent = true })
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
-- claude
vim.keymap.set("n", "<leader>Cb", "<cmd>terminal claude<cr><cmd>silent! file term://claude<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ct", "<cmd>tabedit term://claude<cr><cmd>silent! file term://claude<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ch", "<cmd>vnew<cr><cmd>terminal claude<cr><cmd>silent! file term://claude<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Cj", "<cmd>belowright new<cr><cmd>terminal claude<cr><cmd>silent! file term://claude<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ck", "<cmd>new<cr><cmd>terminal claude<cr><cmd>silent! file term://claude<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>CK", "<cmd>new<cr><cmd>terminal claude<cr><cmd>wincmd K<cr><cmd>resize 10<cr><cmd>silent! file term://claude<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Cl", "<cmd>belowright vnew<cr><cmd>terminal claude<cr><cmd>silent! file term://claude<cr><cmd>startinsert<cr>")

-- top
vim.keymap.set("n", "<leader>Pb", "<cmd>terminal top<cr><cmd>silent! file term://top<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Pt", "<cmd>tabedit term://top<cr><cmd>silent! file term://top<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ph", "<cmd>vnew<cr><cmd>terminal top<cr><cmd>silent! file term://top<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Pj", "<cmd>belowright new<cr><cmd>terminal top<cr><cmd>silent! file term://top<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Pk", "<cmd>new<cr><cmd>terminal top<cr><cmd>silent! file term://top<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Pl", "<cmd>belowright vnew<cr><cmd>terminal top<cr><cmd>silent! file term://top<cr><cmd>startinsert<cr>")

-- ipython
vim.keymap.set("n", "<leader>Ib", "<cmd>terminal ipython<cr><cmd>silent! file term://ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>It", "<cmd>tabedit term://ipython<cr><cmd>silent! file term://ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ih", "<cmd>vnew<cr><cmd>terminal ipython<cr><cmd>silent! file term://ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ij", "<cmd>belowright new<cr><cmd>terminal ipython<cr><cmd>silent! file term://ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>IJ", "<cmd>belowright new<cr><cmd>terminal ipython<cr><cmd>wincmd J<cr><cmd>resize 25<cr><cmd>silent! file term://ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Ik", "<cmd>new<cr><cmd>terminal ipython<cr><cmd>silent! file term://ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>IK", "<cmd>new +terminal ipython<cr><cmd>wincmd K<cr><cmd>resize 10<cr><cmd>silent! file term://ipython<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Il", "<cmd>belowright vnew<cr><cmd>terminal ipython<cr><cmd>silent! file term://ipython<cr><cmd>startinsert<cr>")

-- terminal
vim.keymap.set("n", "<leader>Tb", "<cmd>terminal<cr><cmd>silent! file term://terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Tt", "<cmd>tabedit +terminal<cr><cmd>silent! file term://terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Th", "<cmd>vnew +terminal<cr><cmd>silent! file term://terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>TH", "<cmd>vnew +terminal<cr><cmd>wincmd H<cr><cmd>silent! file term://terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Tj", "<cmd>belowright new +terminal<cr><cmd>silent! file term://terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>TJ", "<cmd>belowright new +terminal<cr><cmd>wincmd J<cr><cmd>resize 25<cr><cmd>silent! file term://terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Tk", "<cmd>new +terminal<cr><cmd>silent! file term://terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>TK", "<cmd>new +terminal<cr><cmd>wincmd K<cr><cmd>resize 10<cr><cmd>silent! file term://terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>Tl", "<cmd>belowright vnew +terminal<cr><cmd>silent! file term://terminal<cr><cmd>startinsert<cr>")
vim.keymap.set("n", "<leader>TL", "<cmd>belowright vnew +terminal<cr><cmd>wincmd L<cr><cmd>silent! file term://terminal<cr><cmd>startinsert<cr>")
-- }}}
