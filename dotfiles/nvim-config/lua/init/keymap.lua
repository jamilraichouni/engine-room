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
vim.keymap.set("n", "<leader>Lsp", "<cmd>e ~/.config/nvim/lua/init/lsp.lua<cr>", { silent = true })

-- dedent in insert mode
vim.keymap.set("i", "<S-Tab>", "<C-d>")

-- Disable arrow keys in visual mode
vim.keymap.set("v", "<left>", "<nop>")
vim.keymap.set("v", "<right>", "<nop>")
vim.keymap.set("v", "<up>", "<nop>")
vim.keymap.set("v", "<down>", "<nop>")

-- unfold and on top
vim.keymap.set("n", "<leader>zo", "<cmd>normal zt<cr><cmd>normal zO<cr>", { silent = true })

-- outline
vim.keymap.set("n", "grf", "<cmd>lua vim.g.FormatCode()<cr>", { silent = true })
vim.keymap.set("n", "gO", "<cmd>pyfile ~/engine-room/dotfiles/nvim-config/jopilot/src/jopilot/outline.py<cr>",
    { silent = true })

-- Gitsign hunk navigation
vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<cr>", { silent = true })
vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<cr>", { silent = true })

-- diff keymaps (do -> obtain, dp -> put)
vim.keymap.set("n", "<leader>dt", "<cmd>windo diffthis<cr>", { silent = true })
vim.keymap.set("n", "<leader>do", "<cmd>windo diffoff<cr>", { silent = true })

-- edit specific files {{{
vim.keymap.set("n", "<leader>Auto", "<cmd>e ~/.config/nvim/lua/init/autocmd.lua<cr>", { silent = true })
vim.keymap.set("n", "<leader>Init", "<cmd>e ~/.config/nvim/lua<cr>", { silent = true })
vim.keymap.set("n", "<leader>Jo", "<cmd>e ~/.config/nvim/jopilot/src/jopilot<cr>", { silent = true })
vim.keymap.set("n", "<leader>Key", "<cmd>e ~/.config/nvim/lua/init/keymap.lua<cr>", { silent = true })
vim.keymap.set("n", "<leader>Plug", "<cmd>Oil ~/.config/nvim/lua/plugins<cr>", { silent = true })
vim.keymap.set("n", "<leader>Cfg", "<cmd>Oil ~/.config/nvim<cr>", { silent = true })
vim.keymap.set("n", "<leader>Doc", "<cmd>tabnew $DOT/nvim-config/docs/JARDOC.md<cr>", { silent = true })

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
-- console
vim.keymap.set("n",
    "<leader>Cb",
    "<cmd>lua vim.g.console()<cr>"
)
vim.keymap.set("n",
    "<leader>Ct",
    "<cmd>tabnew<cr><cmd>lua vim.g.console()<cr>"
)
vim.keymap.set("n",
    "<leader>Ch",
    "<cmd>vnew<cr><cmd>lua vim.g.console()<cr>"
)
vim.keymap.set("n",
    "<leader>CH",
    "<cmd>vnew<cr><cmd>lua vim.g.console()<cr><cmd>wincmd H<cr>"
)
vim.keymap.set("n",
    "<leader>Cj",
    "<cmd>belowright new<cr><cmd>lua vim.g.console()<cr>"
)
vim.keymap.set("n",
    "<leader>CJ",
    "<cmd>belowright new<cr><cmd>lua vim.g.console()<cr><cmd>wincmd J<cr><cmd>resize 25<cr>"
)
vim.keymap.set("n",
    "<leader>Ck",
    "<cmd>new<cr><cmd>lua vim.g.console()<cr>"
)
vim.keymap.set("n",
    "<leader>CK",
    "<cmd>lua vim.g.console()<cr><cmd>wincmd K<cr><cmd>resize 10<cr>"
)
vim.keymap.set("n",
    "<leader>Cl",
    "<cmd>belowright vnew<cr><cmd>lua vim.g.console()<cr>"
)
vim.keymap.set("n",
    "<leader>CL",
    "<cmd>belowright vnew<cr><cmd>wincmd L<cr><cmd>lua vim.g.console()<cr>"
)

-- opencode
vim.keymap.set("n",
    "<leader>Ab",
    "<cmd>lua vim.g.opencode()<cr>"
)
vim.keymap.set("n",
    "<leader>At",
    "<cmd>tabnew<cr><cmd>lua vim.g.opencode()<cr>"
)
vim.keymap.set("n",
    "<leader>Ah",
    "<cmd>vnew<cr><cmd>lua vim.g.opencode()<cr>"
)
vim.keymap.set("n",
    "<leader>AH",
    "<cmd>vnew<cr><cmd>lua vim.g.opencode()<cr><cmd>wincmd H<cr>"
)
vim.keymap.set("n",
    "<leader>Aj",
    "<cmd>belowright new<cr><cmd>lua vim.g.opencode()<cr>"
)
vim.keymap.set("n",
    "<leader>AJ",
    "<cmd>belowright new<cr><cmd>lua vim.g.opencode()<cr><cmd>wincmd J<cr><cmd>resize 25<cr>"
)
vim.keymap.set("n",
    "<leader>Ak",
    "<cmd>new<cr><cmd>lua vim.g.opencode()<cr>"
)
vim.keymap.set("n",
    "<leader>AK",
    "<cmd>lua vim.g.opencode()<cr><cmd>wincmd K<cr><cmd>resize 10<cr>"
)
vim.keymap.set("n",
    "<leader>Al",
    "<cmd>belowright vnew<cr><cmd>lua vim.g.opencode()<cr>"
)
vim.keymap.set("n",
    "<leader>AL",
    "<cmd>belowright vnew<cr><cmd>wincmd L<cr><cmd>lua vim.g.opencode()<cr>"
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

