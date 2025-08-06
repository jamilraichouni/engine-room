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
vim.keymap.set("n", "<leader>ww", "<cmd>vertical resize 86<cr>")

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
vim.keymap.set("n", "<leader>zo", "<cmd>normal zt<cr><cmd>normal zO<cr>", { silent = true })

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
vim.keymap.set("n",
    "<leader>Cb",
    "<cmd>lua vim.g.claude()<cr>"
)
vim.keymap.set("n",
    "<leader>Ct",
    "<cmd>tabnew<cr><cmd>lua vim.g.claude()<cr>"
)
vim.keymap.set("n",
    "<leader>Ch",
    "<cmd>vnew<cr><cmd>lua vim.g.claude()<cr>"
)
vim.keymap.set("n",
    "<leader>CH",
    "<cmd>vnew<cr><cmd>lua vim.g.claude()<cr><cmd>wincmd H<cr>"
)
vim.keymap.set("n",
    "<leader>Cj",
    "<cmd>belowright new<cr><cmd>lua vim.g.claude()<cr>"
)
vim.keymap.set("n",
    "<leader>CJ",
    "<cmd>belowright new<cr><cmd>lua vim.g.claude()<cr><cmd>wincmd J<cr><cmd>resize 25<cr>"
)
vim.keymap.set("n",
    "<leader>Ck",
    "<cmd>new<cr><cmd>lua vim.g.claude()<cr>"
)
vim.keymap.set("n",
    "<leader>CK",
    "<cmd>lua vim.g.claude()<cr><cmd>wincmd K<cr><cmd>resize 10<cr>"
)
vim.keymap.set("n",
    "<leader>Cl",
    "<cmd>belowright vnew<cr><cmd>lua vim.g.claude()<cr>"
)
vim.keymap.set("n",
    "<leader>CL",
    "<cmd>belowright vnew<cr><cmd>wincmd L<cr><cmd>lua vim.g.claude()<cr>"
)

-- top
vim.keymap.set("n",
    "<leader>Pb",
    "<cmd>lua vim.g.top()<cr>"
)
vim.keymap.set("n",
    "<leader>Pt",
    "<cmd>tabnew<cr><cmd>lua vim.g.top()<cr>"
)
vim.keymap.set("n",
    "<leader>Ph",
    "<cmd>vnew<cr><cmd>lua vim.g.top()<cr>"
)
vim.keymap.set("n",
    "<leader>PH",
    "<cmd>vnew<cr><cmd>lua vim.g.top()<cr><cmd>wincmd H<cr>"
)
vim.keymap.set("n",
    "<leader>Pj",
    "<cmd>belowright new<cr><cmd>lua vim.g.top()<cr>"
)
vim.keymap.set("n",
    "<leader>PJ",
    "<cmd>belowright new<cr><cmd>lua vim.g.top()<cr><cmd>wincmd J<cr><cmd>resize 25<cr>"
)
vim.keymap.set("n",
    "<leader>Pk",
    "<cmd>new<cr><cmd>lua vim.g.top()<cr>"
)
vim.keymap.set("n",
    "<leader>PK",
    "<cmd>lua vim.g.top()<cr><cmd>wincmd K<cr><cmd>resize 10<cr>"
)
vim.keymap.set("n",
    "<leader>Pl",
    "<cmd>belowright vnew<cr><cmd>lua vim.g.top()<cr>"
)
vim.keymap.set("n",
    "<leader>PL",
    "<cmd>belowright vnew<cr><cmd>wincmd L<cr><cmd>lua vim.g.top()<cr>"
)

-- ipython
vim.keymap.set("n",
    "<leader>Ib",
    "<cmd>lua vim.g.ipython()<cr>"
)
vim.keymap.set("n",
    "<leader>It",
    "<cmd>tabnew<cr><cmd>lua vim.g.ipython()<cr>"
)
vim.keymap.set("n",
    "<leader>Ih",
    "<cmd>vnew<cr><cmd>lua vim.g.ipython()<cr>"
)
vim.keymap.set("n",
    "<leader>IH",
    "<cmd>vnew<cr><cmd>lua vim.g.ipython()<cr><cmd>wincmd H<cr>"
)
vim.keymap.set("n",
    "<leader>Ij",
    "<cmd>belowright new<cr><cmd>lua vim.g.ipython()<cr>"
)
vim.keymap.set("n",
    "<leader>IJ",
    "<cmd>belowright new<cr><cmd>lua vim.g.ipython()<cr><cmd>wincmd J<cr><cmd>resize 25<cr>"
)
vim.keymap.set("n",
    "<leader>Ik",
    "<cmd>new<cr><cmd>lua vim.g.ipython()<cr>"
)
vim.keymap.set("n",
    "<leader>IK",
    "<cmd>lua vim.g.ipython()<cr><cmd>wincmd K<cr><cmd>resize 10<cr>"
)
vim.keymap.set("n",
    "<leader>Il",
    "<cmd>belowright vnew<cr><cmd>lua vim.g.ipython()<cr>"
)
vim.keymap.set("n",
    "<leader>IL",
    "<cmd>belowright vnew<cr><cmd>wincmd L<cr><cmd>lua vim.g.ipython()<cr>"
)
-- terminal
vim.keymap.set("n",
    "<leader>Tb",
    "<cmd>lua vim.g.terminal()<cr>"
)
vim.keymap.set("n",
    "<leader>Tt",
    "<cmd>tabnew<cr><cmd>lua vim.g.terminal()<cr>"
)
vim.keymap.set("n",
    "<leader>Th",
    "<cmd>vnew<cr><cmd>lua vim.g.terminal()<cr>"
)
vim.keymap.set("n",
    "<leader>TH",
    "<cmd>vnew<cr><cmd>lua vim.g.terminal()<cr><cmd>wincmd H<cr>"
)
vim.keymap.set("n",
    "<leader>Tj",
    "<cmd>belowright new<cr><cmd>lua vim.g.terminal()<cr>"
)
vim.keymap.set("n",
    "<leader>TJ",
    "<cmd>belowright new<cr><cmd>lua vim.g.terminal()<cr><cmd>wincmd J<cr><cmd>resize 25<cr>"
)
vim.keymap.set("n",
    "<leader>Tk",
    "<cmd>new<cr><cmd>lua vim.g.terminal()<cr>"
)
vim.keymap.set("n",
    "<leader>TK",
    "<cmd>lua vim.g.terminal()<cr><cmd>wincmd K<cr><cmd>resize 10<cr>"
)
vim.keymap.set("n",
    "<leader>Tl",
    "<cmd>belowright vnew<cr><cmd>lua vim.g.terminal()<cr>"
)
vim.keymap.set("n",
    "<leader>TL",
    "<cmd>belowright vnew<cr><cmd>wincmd L<cr><cmd>lua vim.g.terminal()<cr>"
)
-- }}}
