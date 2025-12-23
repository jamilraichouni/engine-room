return {
    -- https://github.com/github/copilot.vim {{{
    {
        "github/copilot.vim",
        lazy = false,
        event = "InsertEnter",
        config = function()
            vim.keymap.set("i", "<c-a>", "copilot#Accept('\\<CR>')", {
                expr = true,
                replace_keycodes = false
            })
            vim.keymap.set("i", "<c-w>", "<Plug>(copilot-accept-word)")
            vim.keymap.set("i", "<c-l>", "<Plug>(copilot-accept-line)")
            vim.keymap.set("i", "<c-j>", "<Plug>(copilot-next)")
            vim.keymap.set("i", "<c-k>", "<Plug>(copilot-previous)")
            vim.keymap.set("i", "<c-e>", "<Plug>(copilot-dismiss)")
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_filetypes = {
                ['*'] = true,
                sh = function()
                    if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
                        -- disable for .env files
                        return false
                    end
                    return true
                end,
            }
        end,
    },
    -- }}}
    -- https://github.com/zbirenbaum/copilot.lua {{{
    {
        "zbirenbaum/copilot.lua",
        enabled = false,
        cmd = "Copilot",
        build = ":Copilot auth",
        event = "InsertEnter",
        config = function()
            require('copilot').setup({
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    hide_during_completion = true,
                    debounce = 75,
                    trigger_on_accept = false,
                    keymap = {
                        accept_word = "<c-w>",
                        accept_line = "<c-l>",
                        accept = "<c-a>",
                        next = "<c-j>",
                        prev = "<c-k>",
                        dismiss = "<c-e>",
                    },
                },
                filetypes = {
                    -- gitcommit = true,
                    -- markdown = true,
                    -- python = true,
                    -- yaml = true,
                    sh = function()
                        if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
                            -- disable for .env files
                            return false
                        end
                        return true
                    end,
                    ["*"] = true
                },
                should_attach = function(_, _)
                    return true
                end,
                logger = {
                    file = "/tmp/copilot-lua.log",
                    file_log_level = vim.log.levels.OFF,
                    print_log_level = vim.log.levels.ERROR,
                    trace_lsp = "off", -- "off" | "messages" | "verbose"
                    trace_lsp_progress = false,
                    log_lsp_messages = false,
                },
            })
        end,
    },
    -- }}}
}
-- vim: foldmethod=marker:foldlevel=10:foldenable

