return {
    -- https://github.com/github/copilot.vim {{{
    {
        "github/copilot.vim",
        cmd = "Copilot",
        lazy = false,
        event = "InsertEnter",
        config = function()
            vim.keymap.set('i', '<c-a>', 'copilot#Accept("\\<CR>")', {
                expr = true,
                replace_keycodes = false
            })
            vim.keymap.set('i', '<c-l>', '<Plug>(copilot-accept-line)')
            vim.keymap.set('i', '<c-w>', '<Plug>(copilot-accept-word)')
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_filetypes = {
                ['*'] = true,
            }
        end,
    },
    -- }}}
}
