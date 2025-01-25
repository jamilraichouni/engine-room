return {
    -- https://github.com/zbirenbaum/copilot.lua {{{
    {
        "zbirenbaum/copilot.lua",
        -- cond = function() return vim.env.NVIM == nil and vim.fn.executable("node") == 1 end,
        cmd = { "Copilot" },
        event = "InsertEnter",
        opts = {
            filetypes = {
                -- gitcommit = true,
                -- markdown = true,
                -- python = true,
                -- yaml = true,
                ["*"] = true
            },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                hide_during_completion = true,
                debounce = 75,
                keymap = {
                    accept = "<c-a>",
                    accept_word = "<c-w>",
                    accept_line = "<c-l>",
                    next = "<c-j>",
                    prev = "<c-k>",
                    -- dismiss = "<C-]>",
                },
            },
        },
        -- config = function()
        --     require("copilot").setup(opts)
        -- end,
    },
    -- }}}
    -- https://github.com/AndreM222/copilot-lualine {{{
    { 'AndreM222/copilot-lualine' }
    -- }}}
}
