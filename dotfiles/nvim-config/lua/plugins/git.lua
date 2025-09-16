return {
    {
        -- https://github.com/tpope/vim-fugitive
        "tpope/vim-fugitive",
        cmd = { "G", "Gclog" },
        event = { "VeryLazy" },
        config = function()
            vim.keymap.set('n', '<leader>Gb', '<cmd>G<cr>', { silent = true })
            -- FIXME: Gh behaves weird
            vim.keymap.set('n', '<leader>Gh', '<cmd>vnew +G<cr>', { silent = true })
            vim.keymap.set('n', '<leader>Gj', '<cmd>belowright new +G<cr>', { silent = true })
            vim.keymap.set('n', '<leader>Gk', '<cmd>new +G<cr>', { silent = true })
            vim.keymap.set('n', '<leader>Gl', '<cmd>belowright vnew +G<cr>', { silent = true })
            vim.keymap.set('n', '<leader>Gt', '<cmd>tabedit +G<cr><cmd>TabooRename Git<cr>', { silent = true })
        end,
    },
    {
        -- https://github.com/lewis6991/gitsigns.nvim
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        config = function()
            require("gitsigns").setup({
                diff_opts = {
                    vertical = false
                }
            })
            vim.keymap.set('n', '<leader>gd', '<cmd>Gitsigns diffthis<cr>', { silent = true })
            vim.keymap.set('n', '<leader>[g', '<cmd>Gitsigns prev_hunk<cr>', { silent = true })
            vim.keymap.set('n', '<leader>]g', '<cmd>Gitsigns next_hunk<cr>', { silent = true })
            vim.keymap.set('n', '<leader>gp', '<cmd>Gitsigns preview_hunk<cr>', { silent = true })
            vim.keymap.set('n', '<leader>gs', '<cmd>Gitsigns stage_hunk<cr>', { silent = true })
            vim.keymap.set('n', '<leader>gr', '<cmd>Gitsigns reset_hunk<cr>', { silent = true })
        end
    },
}
